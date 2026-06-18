# NexusShop

NexusShop is a Java 17 e-commerce application built with JSP, Servlets, Maven, and a Tomcat-deployable WAR package.

This repository is prepared for:

- local development on Windows and macOS
- IntelliJ IDEA import
- Maven build with `mvn clean package`
- SQL Server as the default database
- portable database configuration through `db.properties`, JVM properties, or environment variables

## Stack

- Java: 17
- Build tool: Maven
- Packaging: WAR
- Web container: Tomcat 9
- Default database: SQL Server

Important Tomcat note:

- Tomcat 9 is the direct target for this codebase because it uses the `javax.servlet` API.
- Tomcat 10 can still be used after Jakarta migration with the Apache Tomcat migration tool or Tomcat's Java EE migration workflow.

## Project Structure

```text
nexusshop/
├── pom.xml
├── README.md
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/nexusshope/
│   │   │       ├── config/
│   │   │       ├── dao/
│   │   │       ├── model/
│   │   │       ├── service/
│   │   │       ├── servlet/
│   │   │       └── utill/
│   │   ├── resources/
│   │   │   ├── db.properties
│   │   │   └── db.properties.example
│   │   └── webapp/
│   └── ...
└── database/
    └── sqlserver/
```

Layering in the application:

- `dao/`: database access only
- `service/`: business logic and validation
- `servlet/`: HTTP controllers and view routing

## System Requirements

- JDK 17
- Maven 3.9 or newer
- Tomcat 9.0.x
- SQL Server 2019+, SQL Server Express, or Azure SQL Database
- A SQL tool such as SSMS, Azure Data Studio, or `sqlcmd`

## Database Configuration

The application no longer keeps database credentials in Java source code.

It loads configuration in this order:

1. JVM system properties:
   - `db.driver`
   - `db.url`
   - `db.username`
   - `db.password`
2. Environment variables:
   - `DB_DRIVER`
   - `DB_URL`
   - `DB_USERNAME`
   - `DB_PASSWORD`
   - legacy aliases `NEXUS_DB_*`
3. External file from `-Dnexusshop.db.config=/path/to/db.properties`
4. `${catalina.base}/conf/nexusshop/db.properties`
5. `config/db.properties` from the working directory
6. `db.properties` from the working directory
7. `src/main/resources/db.properties` on the classpath

Current connection handling is centralized in:

- [DatabaseConfig.java](/Users/ruchira/Documents/Playground/nexusshop/nexusshop/src/main/java/com/nexusshope/config/DatabaseConfig.java)
- [DBUtil.java](/Users/ruchira/Documents/Playground/nexusshop/nexusshop/src/main/java/com/nexusshope/utill/DBUtil.java)

## Configure `db.properties`

Edit:

- [db.properties](/Users/ruchira/Documents/Playground/nexusshop/nexusshop/src/main/resources/db.properties)

Reference examples:

- [db.properties.example](/Users/ruchira/Documents/Playground/nexusshop/nexusshop/src/main/resources/db.properties.example)

Default local SQL Server template:

```properties
db.driver=com.microsoft.sqlserver.jdbc.SQLServerDriver
db.url=jdbc:sqlserver://localhost:1433;databaseName=NexusShop2;encrypt=true;trustServerCertificate=true;
db.username=sa
db.password=your_password
```

Azure SQL example:

```properties
db.driver=com.microsoft.sqlserver.jdbc.SQLServerDriver
db.url=jdbc:sqlserver://your-server.database.windows.net:1433;databaseName=NexusShop2;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;
db.username=your_sql_admin_user
db.password=your_password
```

Generic JDBC note:

- The config system supports any JDBC URL and driver class.
- The current schema and DAO SQL are written for SQL Server.
- If you switch to another database vendor, you may also need vendor-compatible SQL scripts, stored procedures, and the matching JDBC driver dependency in `pom.xml`.

## Database Setup

### Local SQL Server

1. Install SQL Server or SQL Server Express.
2. Create a database named `NexusShop2`.
3. Run these scripts in order:
   - [01-core-schema.sql](/Users/ruchira/Documents/Playground/nexusshop/nexusshop/database/sqlserver/01-core-schema.sql)
   - [02-cart-faq.sql](/Users/ruchira/Documents/Playground/nexusshop/nexusshop/database/sqlserver/02-cart-faq.sql)
   - [03-orders.sql](/Users/ruchira/Documents/Playground/nexusshop/nexusshop/database/sqlserver/03-orders.sql)
4. Update `src/main/resources/db.properties` with your local connection details.

### Azure SQL Database

1. Create an Azure SQL Database named `NexusShop2`.
2. Create or choose a SQL Server instance in Azure.
3. Allow your local machine IP in the Azure SQL firewall settings.
4. Run the same SQL scripts in order:
   - [01-core-schema.sql](/Users/ruchira/Documents/Playground/nexusshop/nexusshop/database/sqlserver/01-core-schema.sql)
   - [02-cart-faq.sql](/Users/ruchira/Documents/Playground/nexusshop/nexusshop/database/sqlserver/02-cart-faq.sql)
   - [03-orders.sql](/Users/ruchira/Documents/Playground/nexusshop/nexusshop/database/sqlserver/03-orders.sql)
5. Update `db.properties` with the Azure JDBC URL, username, and password.

## Import Into IntelliJ IDEA

1. Open IntelliJ IDEA.
2. Choose `Open`.
3. Select the project folder:
   - `/Users/ruchira/Documents/Playground/nexusshop/nexusshop`
4. Let IntelliJ import it as a Maven project.
5. Set the Project SDK to Java 17.
6. Wait for Maven dependencies to finish indexing.
7. Confirm that `src/main/resources/db.properties` contains valid DB settings.

## Configure Tomcat In IntelliJ

### Tomcat 9

1. Install Tomcat 9 locally.
2. In IntelliJ, open `Run | Edit Configurations`.
3. Add a new `Tomcat Server | Local`.
4. Point it to your Tomcat 9 installation.
5. In `Deployment`, add the WAR artifact for NexusShop.
6. In `Server`, keep the default HTTP port `8080` or change it if needed.
7. Start the server.

Optional external config:

- Add a VM option such as:

```text
-Dnexusshop.db.config=/absolute/path/to/db.properties
```

### Tomcat 10

Because this project currently targets the `javax.servlet` API, Tomcat 10 requires a Jakarta migration step before deployment.

Recommended options:

1. Use Tomcat 9 for local development.
2. If Tomcat 10 is required, migrate the WAR with the Apache Tomcat migration tool before deploying it.

## Build The WAR

From the project root run:

```bash
mvn clean package
```

Generated artifact:

```text
target/nexusshop-1.0-SNAPSHOT.war
```

## Deploy The WAR

### Local Tomcat

1. Build the WAR with Maven.
2. Copy `target/nexusshop-1.0-SNAPSHOT.war` into Tomcat's `webapps` directory.
3. Make sure `db.properties` is available either:
   - inside the classpath resource, or
   - via `-Dnexusshop.db.config=/path/to/db.properties`, or
   - in `${catalina.base}/conf/nexusshop/db.properties`
4. Start Tomcat.
5. Open:

```text
http://localhost:8080/nexusshop-1.0-SNAPSHOT/
```

If you deploy the WAR as `ROOT.war`, open:

```text
http://localhost:8080/
```

## Existing Functionality Preserved

The refactor keeps the existing application flow intact:

- login and registration
- product browsing
- cart management
- order creation and checkout

## Troubleshooting

### 1. JDBC driver not found

Symptom:

- startup fails with a `JDBC driver not found` message

Fix:

- confirm the SQL Server JDBC dependency resolves through Maven
- run `mvn clean package` again
- if you switch to another database vendor, add that vendor's JDBC driver dependency to `pom.xml`

### 2. Database login failed

Symptom:

- `Login failed for user`
- `Cannot open database requested by the login`

Fix:

- confirm `db.username` and `db.password`
- confirm the database name is exactly `NexusShop2`
- for Azure SQL, confirm firewall rules allow your IP

### 3. Port 8080 already in use

Symptom:

- Tomcat fails to start

Fix:

- change the Tomcat port in IntelliJ run configuration
- or stop the process already using port `8080`

### 4. SQL Server connection refused

Symptom:

- connection timeout or refused connection

Fix:

- confirm SQL Server is running
- confirm TCP/IP is enabled in SQL Server Configuration Manager
- confirm the JDBC URL points to the correct host and port

### 5. `db.properties` changes are not picked up

Fix:

- rebuild the project if you changed the classpath resource file
- or prefer an external file with:

```text
-Dnexusshop.db.config=/absolute/path/to/db.properties
```

### 6. WAR works on Tomcat 9 but not Tomcat 10

Fix:

- deploy on Tomcat 9 directly
- or migrate the WAR to Jakarta before deploying to Tomcat 10

## Notes For GitHub And Team Use

- keep real secrets out of source control
- use `db.properties.example` as the safe shared reference
- prefer external `db.properties` files or environment variables for team and cloud environments

## Useful Files

- [pom.xml](/Users/ruchira/Documents/Playground/nexusshop/nexusshop/pom.xml)
- [db.properties](/Users/ruchira/Documents/Playground/nexusshop/nexusshop/src/main/resources/db.properties)
- [db.properties.example](/Users/ruchira/Documents/Playground/nexusshop/nexusshop/src/main/resources/db.properties.example)
- [DBUtil.java](/Users/ruchira/Documents/Playground/nexusshop/nexusshop/src/main/java/com/nexusshope/utill/DBUtil.java)
- [DatabaseConfig.java](/Users/ruchira/Documents/Playground/nexusshop/nexusshop/src/main/java/com/nexusshope/config/DatabaseConfig.java)
- [DEPLOYMENT.md](/Users/ruchira/Documents/Playground/nexusshop/nexusshop/DEPLOYMENT.md)
