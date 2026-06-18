package com.nexusshope.config;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;

public final class DatabaseConfig {
    public static final String CONFIG_RESOURCE = "db.properties";
    public static final String CONFIG_PATH_PROPERTY = "nexusshop.db.config";
    public static final String CONFIG_PATH_ENV = "NEXUS_DB_CONFIG";

    private static final String DRIVER_KEY = "db.driver";
    private static final String URL_KEY = "db.url";
    private static final String USERNAME_KEY = "db.username";
    private static final String PASSWORD_KEY = "db.password";

    private final Properties properties;
    private final String sourceDescription;

    private DatabaseConfig(Properties properties, String sourceDescription) {
        this.properties = properties;
        this.sourceDescription = sourceDescription;
    }

    public static DatabaseConfig load() {
        Properties merged = new Properties();
        List<String> sources = new ArrayList<>();

        loadClasspathProperties(merged, sources);
        loadExternalProperties(merged, sources);
        applySystemPropertyOverrides(merged, sources);
        applyEnvironmentOverrides(merged, sources);

        validate(merged);
        String sourceDescription = sources.isEmpty() ? "no configuration source found" : String.join(" -> ", sources);

        return new DatabaseConfig(merged, sourceDescription);
    }

    public String getDriver() {
        return trimmedValue(DRIVER_KEY);
    }

    public String getUrl() {
        return trimmedValue(URL_KEY);
    }

    public String getUsername() {
        return trimmedValue(USERNAME_KEY);
    }

    public String getPassword() {
        return trimmedValue(PASSWORD_KEY);
    }

    public String getSourceDescription() {
        return sourceDescription;
    }

    private String trimmedValue(String key) {
        String value = properties.getProperty(key);
        return value == null ? "" : value.trim();
    }

    private static void loadClasspathProperties(Properties target, List<String> sources) {
        ClassLoader classLoader = Thread.currentThread().getContextClassLoader();
        if (classLoader == null) {
            classLoader = DatabaseConfig.class.getClassLoader();
        }

        try (InputStream inputStream = classLoader.getResourceAsStream(CONFIG_RESOURCE)) {
            if (inputStream == null) {
                return;
            }

            Properties loaded = new Properties();
            loaded.load(inputStream);
            target.putAll(loaded);
            sources.add("classpath:" + CONFIG_RESOURCE);
        } catch (IOException e) {
            throw new ConfigurationException("Unable to read classpath " + CONFIG_RESOURCE, e);
        }
    }

    private static void loadExternalProperties(Properties target, List<String> sources) {
        Path explicitPath = resolveConfiguredPath();
        if (explicitPath != null) {
            loadFileIfPresent(explicitPath, target, sources, true);
            return;
        }

        String catalinaBase = System.getProperty("catalina.base");
        if (catalinaBase != null && !catalinaBase.trim().isEmpty()) {
            loadFileIfPresent(Paths.get(catalinaBase, "conf", "nexusshop", CONFIG_RESOURCE), target, sources, false);
        }

        loadFileIfPresent(Paths.get("config", CONFIG_RESOURCE), target, sources, false);
        loadFileIfPresent(Paths.get(CONFIG_RESOURCE), target, sources, false);
    }

    private static Path resolveConfiguredPath() {
        String configuredPath = firstNonBlank(
                System.getProperty(CONFIG_PATH_PROPERTY),
                System.getenv(CONFIG_PATH_ENV)
        );

        if (configuredPath == null) {
            return null;
        }

        return Paths.get(configuredPath).toAbsolutePath().normalize();
    }

    private static void loadFileIfPresent(Path path, Properties target, List<String> sources, boolean required) {
        if (path == null) {
            return;
        }

        Path normalizedPath = path.toAbsolutePath().normalize();
        if (!Files.exists(normalizedPath)) {
            if (required) {
                throw new ConfigurationException("Configured database properties file not found: " + normalizedPath);
            }
            return;
        }

        try (InputStream inputStream = Files.newInputStream(normalizedPath)) {
            Properties loaded = new Properties();
            loaded.load(inputStream);
            target.putAll(loaded);
            sources.add("file:" + normalizedPath);
        } catch (IOException e) {
            throw new ConfigurationException("Unable to read database properties file: " + normalizedPath, e);
        }
    }

    private static void applySystemPropertyOverrides(Properties target, List<String> sources) {
        applyOverride(target, DRIVER_KEY, System.getProperty(DRIVER_KEY));
        applyOverride(target, URL_KEY, System.getProperty(URL_KEY));
        applyOverride(target, USERNAME_KEY, System.getProperty(USERNAME_KEY));
        applyOverride(target, PASSWORD_KEY, System.getProperty(PASSWORD_KEY));

        if (System.getProperty(DRIVER_KEY) != null
                || System.getProperty(URL_KEY) != null
                || System.getProperty(USERNAME_KEY) != null
                || System.getProperty(PASSWORD_KEY) != null) {
            sources.add("system-properties");
        }
    }

    private static void applyEnvironmentOverrides(Properties target, List<String> sources) {
        applyOverride(target, DRIVER_KEY, firstNonBlank(System.getenv("DB_DRIVER"), System.getenv("NEXUS_DB_DRIVER")));
        applyOverride(target, URL_KEY, firstNonBlank(System.getenv("DB_URL"), System.getenv("NEXUS_DB_URL")));
        applyOverride(target, USERNAME_KEY, firstNonBlank(
                System.getenv("DB_USERNAME"),
                System.getenv("NEXUS_DB_USERNAME"),
                System.getenv("NEXUS_DB_USER")
        ));
        applyOverride(target, PASSWORD_KEY, firstNonBlank(System.getenv("DB_PASSWORD"), System.getenv("NEXUS_DB_PASSWORD")));

        if (System.getenv("DB_DRIVER") != null
                || System.getenv("NEXUS_DB_DRIVER") != null
                || System.getenv("DB_URL") != null
                || System.getenv("NEXUS_DB_URL") != null
                || System.getenv("DB_USERNAME") != null
                || System.getenv("NEXUS_DB_USERNAME") != null
                || System.getenv("NEXUS_DB_USER") != null
                || System.getenv("DB_PASSWORD") != null
                || System.getenv("NEXUS_DB_PASSWORD") != null) {
            sources.add("environment");
        }
    }

    private static void applyOverride(Properties target, String key, String value) {
        if (value != null && !value.trim().isEmpty()) {
            target.setProperty(key, value.trim());
        }
    }

    private static String firstNonBlank(String... values) {
        if (values == null) {
            return null;
        }

        for (String value : values) {
            if (value != null && !value.trim().isEmpty()) {
                return value.trim();
            }
        }

        return null;
    }

    private static void validate(Properties properties) {
        String driver = properties.getProperty(DRIVER_KEY, "").trim();
        String url = properties.getProperty(URL_KEY, "").trim();

        if (driver.isEmpty()) {
            throw new ConfigurationException("Missing required database property: " + DRIVER_KEY);
        }

        if (url.isEmpty()) {
            throw new ConfigurationException("Missing required database property: " + URL_KEY);
        }
    }
}
