package com.nexusshope.utill;

import com.nexusshope.config.ConfigurationException;
import com.nexusshope.config.DatabaseConfig;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;
import java.util.concurrent.atomic.AtomicReference;

public final class DBUtil {
    private static final AtomicReference<String> LOADED_DRIVER = new AtomicReference<>();
    private static volatile DatabaseConfig databaseConfig = DatabaseConfig.load();

    private DBUtil() {
    }

    public static Connection getConnection() throws SQLException {
        DatabaseConfig config = databaseConfig;
        ensureDriverLoaded(config.getDriver());

        Properties connectionProperties = new Properties();
        if (!config.getUsername().isEmpty()) {
            connectionProperties.setProperty("user", config.getUsername());
        }
        if (!config.getPassword().isEmpty()) {
            connectionProperties.setProperty("password", config.getPassword());
        }

        return DriverManager.getConnection(config.getUrl(), connectionProperties);
    }

    public static void reloadConfiguration() {
        databaseConfig = DatabaseConfig.load();
        LOADED_DRIVER.set(null);
    }

    public static String getConfigurationSourceDescription() {
        return databaseConfig.getSourceDescription();
    }

    private static void ensureDriverLoaded(String driverClassName) {
        String alreadyLoaded = LOADED_DRIVER.get();
        if (driverClassName.equals(alreadyLoaded)) {
            return;
        }

        synchronized (DBUtil.class) {
            alreadyLoaded = LOADED_DRIVER.get();
            if (driverClassName.equals(alreadyLoaded)) {
                return;
            }

            try {
                Class.forName(driverClassName);
                LOADED_DRIVER.set(driverClassName);
            } catch (ClassNotFoundException e) {
                throw new ConfigurationException("JDBC driver not found: " + driverClassName, e);
            }
        }
    }
}
