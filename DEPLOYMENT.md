# NexusShop Deployment Guide

This project is a Java 17 + JSP/Servlet + Tomcat application with a SQL Server database.

## Recommended free deployment path

- App hosting: Render web service
- Database: Azure SQL Database free offer

Vercel is not a fit for this codebase because the app is not a serverless Node/Python/Go/Ruby function app. It is a WAR app that runs on Tomcat.

## Before you start

Make sure you already have:

- The code pushed to GitHub
- A Render account
- An Azure account

GitHub repo:

- `https://github.com/Ruchira20031209/nexusshop`

## 1. Create the Azure SQL database

1. Sign in to Azure.
2. Create a new `SQL Database`.
3. Use database name `NexusShop2`.
4. Create a new SQL server when Azure asks:
   - Save the `Server name`
   - Save the SQL admin `Username`
   - Save the SQL admin `Password`
5. In networking, keep public access enabled so Render can connect.
6. Finish creating the database.

After creation, note these values:

- Server name, usually like `your-server.database.windows.net`
- Database name: `NexusShop2`
- SQL admin username
- SQL admin password

## 2. Import the SQL scripts

Run these files in this exact order:

1. `database/sqlserver/01-core-schema.sql`
2. `database/sqlserver/02-cart-faq.sql`
3. `database/sqlserver/03-orders.sql`

Easy way:

1. Open your database in the Azure portal.
2. Open `Query editor`.
3. Paste the SQL from each file one by one.
4. Run each script before moving to the next one.

If one script creates objects used by the next script, order matters.

## 3. Create the Render web service

1. Sign in to Render.
2. Click `New`.
3. Choose `Web Service`.
4. Connect your GitHub account if Render asks.
5. Select repo `Ruchira20031209/nexusshop`.
6. Render should detect the `Dockerfile`.
7. Use these values:
   - Name: `nexusshop`
   - Branch: `main`
   - Runtime: `Docker`
   - Plan: `Free` or `Hobby ($0)` if Render shows that label
8. Continue to environment variables.

## 4. Add the environment variables in Render

Add these three variables:

- `NEXUS_DB_URL`
- `NEXUS_DB_USERNAME`
- `NEXUS_DB_PASSWORD`

Use this value format for `NEXUS_DB_URL`:

```text
jdbc:sqlserver://YOUR_SERVER.database.windows.net:1433;databaseName=NexusShop2;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;
```

Example:

```text
jdbc:sqlserver://nexusshop-sql.database.windows.net:1433;databaseName=NexusShop2;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;
```

For the other two variables:

- `NEXUS_DB_USERNAME`: your Azure SQL admin username
- `NEXUS_DB_PASSWORD`: your Azure SQL admin password

## 5. Allow Render to access Azure SQL

Azure SQL blocks unknown IPs by default. Render must be allowlisted.

1. In Render, open your service dashboard.
2. Find the outbound IP ranges for your service region or workspace.
3. Copy the CIDR/IP ranges.
4. In Azure, open the SQL server for your database.
5. Open `Networking` or `Firewalls and virtual networks`.
6. Make sure public network access is enabled for selected networks.
7. Add firewall rules for the Render outbound IP ranges.
8. Save the firewall rules.

If you do not add the Render IP ranges, the deployed app usually builds fine but cannot connect to the database.

## 6. Deploy

1. Back in Render, click `Create Web Service` or `Deploy`.
2. Wait for the Docker build and deploy to finish.
3. Open the Render URL.
4. Test:
   - home page
   - login
   - product list
   - cart
   - order flow

## 7. If the app opens but DB features fail

Check these first:

- `NEXUS_DB_URL` has the right Azure server name
- database name is exactly `NexusShop2`
- all three SQL scripts were run
- Azure firewall includes the Render outbound IP ranges
- Render service finished deploying successfully

## Important free-tier notes

- Render free web services spin down after 15 minutes of no traffic and can take about one minute to wake back up.
- Render free services have monthly hour limits.
- Azure SQL Database currently advertises a free monthly allowance, but you should still watch your Azure cost dashboard.
- This setup is fine for learning, demos, and portfolio hosting, not serious production traffic.

## Future updates

After this first deployment, future changes are simple:

1. Edit your code locally.
2. Commit and push to GitHub.
3. Render automatically redeploys from the `main` branch.
