+++
title =  "Postgres to Neo4j Workflow"
description = "Streamlining Data Transfer from PostgreSQL to Neo4j with Java"
tags = ['python', "mysql","databases"]
images = ["images/feature-image.png"]
date = "2024-08-06T15:10:02-05:00"
categories = ["projects"]
series = ["Java"]
[extra]
lang = "en"
toc = true
comment = false
copy = true
outdate_alert = true
outdate_alert_days = 120
math = false
mermaid = false
featured = false
reaction = false
+++

# Streamlining Data Transfer from PostgreSQL to Neo4j with Java

In my previous few posts I put together a postgres db of supreme court meta data. That is cool. I have a few more ideas.. but I wanted to explore the graph a bit before expanding it with some nlp.  So in this post I am writing about how to ingest a bunch of nodes into neo4j with a java workflow. In the next post I'll detail adding relationships.. because it is useless without relationships. 

When dealing with large datasets, it's crucial to have an efficient process for transferring data from a relational database like PostgreSQL to a graph database like Neo4j. In this post, we'll walk through how to upload nodes and create relationships in Neo4j using Java, ensuring a modular and maintainable workflow.

## Prerequisites

1. Java Development Kit (JDK) 8 or higher
2. Maven
3. Neo4j and PostgreSQL instances running
4. A .env file for managing environment variables


## Project Setup
Step 1: Create a Maven Project
First, create a new Maven project using the following command:

```sh

mvn archetype:generate -DgroupId=com.supreme_court_transfer -DartifactId=supreme-court-transfer -DarchetypeArtifactId=maven-archetype-quickstart -DinteractiveMode=false

```


### Step 2: Directory Structure

Your project structure should look like this:

```css

supreme-court-transfer/
├── pom.xml
├── src
│   ├── main
│   │   ├── java
│   │   │   └── com
│   │   │       └── supreme_court_transfer
│   │   │           ├── App.java
│   │   │           ├── CallNumber.java
│   │   │           ├── Contributor.java
│   │   │           ├── DataTransferService.java
│   │   │           ├── Item.java
│   │   │           ├── Neo4jConnection.java
│   │   │           ├── PostgresConnection.java
│   │   │           ├── RelationshipCreator.java
│   │   │           ├── Resource.java
│   │   │           └── Subject.java
│   │   └── resources
│   │       └── logback.xml
│   └── test
│       └── java
│           └── com
│               └── supreme_court_transfer
│                   └── AppTest.java

```

### Step 3: Add Dependencies

Update your pom.xml with the necessary dependencies:

```xml

<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.supreme_court_transfer</groupId>
    <artifactId>supreme-court-transfer</artifactId>
    <version>1.0-SNAPSHOT</version>

    <properties>
        <maven.compiler.source>1.8</maven.compiler.source>
        <maven.compiler.target>1.8</maven.compiler.target>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.postgresql</groupId>
            <artifactId>postgresql</artifactId>
            <version>42.3.1</version>
        </dependency>
        <dependency>
            <groupId>org.neo4j.driver</groupId>
            <artifactId>neo4j-java-driver</artifactId>
            <version>4.4.3</version>
        </dependency>
        <dependency>
            <groupId>io.github.cdimascio</groupId>
            <artifactId>dotenv-java</artifactId>
            <version>2.2.0</version>
        </dependency>
        <dependency>
            <groupId>org.slf4j</groupId>
            <artifactId>slf4j-api</artifactId>
            <version>1.7.32</version>
        </dependency>
        <dependency>
            <groupId>ch.qos.logback</groupId>
            <artifactId>logback-classic</artifactId>
            <version>1.2.10</version>
        </dependency>
        <dependency>
            <groupId>junit</groupId>
            <artifactId>junit</artifactId>
            <version>4.12</version>
            <scope>test</scope>
        </dependency>
    </dependencies>
</project>

```

### Managing Environment Variables

### Create a .env file in the root directory of your project:

```plaintext

POSTGRES_URL=jdbc:postgresql://localhost:5432/supreme_court
POSTGRES_USER=example
POSTGRES_PASSWORD=example
NEO4J_URL=bolt://localhost:7687
NEO4J_USER=neo4j
NEO4J_PASSWORD=password
```

## Implementing Data Transfer

### Step 4: Define Entity Classes

Define Java classes for each table in your PostgreSQL database.

#### CallNumber.java

```java

package com.supreme_court_transfer;

public class CallNumber {
    private int id;
    private String callNumber;
    private String externalId;

    // Constructor, getters, and setters
}

```


#### Contributor.java

```java

package com.supreme_court_transfer;

public class Contributor {
    private int id;
    private String externalId;
    private String contributor;

    // Constructor, getters, and setters
}

```

#### Resource.java

```java

package com.supreme_court_transfer;

public class Resource {
    private int id;
    private String pdf;
    private String image;
    private String externalId;

    // Constructor, getters, and setters
}

```

#### Item.java

```java

package com.supreme_court_transfer;

public class Item {
    private int id;
    private String notes;
    private String callNumber;
    private String createdPublished;
    private String title;
    private String date;
    private String sourceCollection;
    private String externalId;

    // Constructor, getters, and setters
}

```


#### Subject.java

```java
package com.supreme_court_transfer;

public class Subject {
    private int id;
    private String externalId;
    private String subject;

    // Constructor, getters, and setters
}
```

### Step 5: Database Connection Classes


#### PostgresConnection.java

```java

package com.supreme_court_transfer;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

import io.github.cdimascio.dotenv.Dotenv;

public class PostgresConnection {
    private static final Dotenv dotenv = Dotenv.load();
    private static final String URL = dotenv.get("POSTGRES_URL");
    private static final String USER = dotenv.get("POSTGRES_USER");
    private static final String PASSWORD = dotenv.get("POSTGRES_PASSWORD");

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}

```

#### Neo4jConnection.java

```java

package com.supreme_court_transfer;

import org.neo4j.driver.AuthTokens;
import org.neo4j.driver.Driver;
import org.neo4j.driver.GraphDatabase;
import org.neo4j.driver.Session;

import io.github.cdimascio.dotenv.Dotenv;

public class Neo4jConnection {
    private static final Dotenv dotenv = Dotenv.load();
    private static final String NEO4J_URL = dotenv.get("NEO4J_URL");
    private static final String NEO4J_USER = dotenv.get("NEO4J_USER");
    private static final String NEO4J_PASSWORD = dotenv.get("NEO4J_PASSWORD");

    private static Driver driver = GraphDatabase.driver(NEO4J_URL, AuthTokens.basic(NEO4J_USER, NEO4J_PASSWORD));

    public static Session getSession() {
        return driver.session();
    }

    public static void close() {
        driver.close();
    }
}

```

### Step 6: Implement Data Transfer Service

#### DataTransferService.java

```java

package com.supreme_court_transfer;

import org.neo4j.driver.Session;
import org.neo4j.driver.Values;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class DataTransferService {
    private static final Logger logger = LoggerFactory.getLogger(DataTransferService.class);

    // CallNumber methods
    public static List<CallNumber> fetchCallNumbersFromPostgres(int limit) throws Exception {
        List<CallNumber> callNumbers = new ArrayList<>();
        Connection postgresConn = PostgresConnection.getConnection();
        Statement stmt = postgresConn.createStatement();
        ResultSet rs = stmt.executeQuery("SELECT id, call_number, external_id FROM callnumbers LIMIT " + limit);

        while (rs.next()) {
            callNumbers.add(new CallNumber(
                    rs.getInt("id"),
                    rs.getString("call_number"),
                    rs.getString("external_id")
            ));
        }

        rs.close();
        stmt.close();
        postgresConn.close();
        logger.info("Fetched {} call numbers from PostgreSQL.", callNumbers.size());
        return callNumbers;
    }

    public static void insertCallNumbersIntoNeo4j(List<CallNumber> callNumbers) {
        Session neo4jSession = Neo4jConnection.getSession();
        for (CallNumber callNumber : callNumbers) {
            neo4jSession.run("CREATE (:CallNumber {id: $id, callNumber: $callNumber, externalId: $externalId})",
                    Values.parameters(
                            "id", callNumber.getId(),
                            "callNumber", callNumber.getCallNumber(),
                            "externalId", callNumber.getExternalId()
                    ));
        }
        neo4jSession.close();
        logger.info("Inserted {} call numbers into Neo4j.", callNumbers.size());
    }

    public static void transferCallNumbers(int limit) throws Exception {
        logger.debug("Starting transfer of call numbers.");
        List<CallNumber> callNumbers = fetchCallNumbersFromPostgres(limit);
        insertCallNumbersIntoNeo4j(callNumbers);
        logger.debug("Completed transfer of call numbers.");
    }

    // Repeat similar methods for other entities: Contributor, Resource, Item, Subject
}
```

### Step 7: Main Application Class

#### App.java

```java

package com.supreme_court_transfer;

import io.github.cdimascio.dotenv.Dotenv;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class App {
    private static final Logger logger = LoggerFactory.getLogger(App.class);

    public static void main(String[] args) {
        // Load environment variables from .env file
        Dotenv dotenv = Dotenv.load();

        // Log to verify environment variables (optional, for debugging purposes)
        logger.debug("Postgres URL: {}", dotenv.get("POSTGRES_URL"));
        logger.debug("Neo4j URL: {}", dotenv.get("NEO4J_URL"));

        int limit = Integer.MAX_VALUE; // Default to no limit

        if (args.length > 0) {
            try {
                limit = Integer.parseInt(args[0]);
            } catch (NumberFormatException e) {
                logger.error("Invalid limit argument, using default value (no limit).", e);
            }
        }

        try {
            logger.info("Starting data transfer process with limit {}...", limit);
            DataTransferService.transferCallNumbers(limit);
            DataTransferService.transferContributors(limit);
            DataTransferService.transferResources(limit);
            DataTransferService.transferItems(limit);
            DataTransferService.transferSubjects(limit);
            logger.info("Data transfer process completed.");
        } catch (Exception e) {
            logger.error("An error occurred during the data transfer process.", e);
        } finally {
            Neo4jConnection.close();
        }
    }
}

```


### Step 8: Create the Relationships

```java
package com.supreme_court_transfer;

import org.neo4j.driver.Session;
import org.neo4j.driver.Transaction;
import org.neo4j.driver.TransactionWork;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class RelationshipCreator {
    private static final Logger logger = LoggerFactory.getLogger(RelationshipCreator.class);

    public static void createRelationships() {
        logger.info("Starting relationship creation process...");

        try (Session session = Neo4jConnection.getSession()) {
            // Relationship creation methods
            createCallNumberToItemRelationships(session);
            createResourceToItemRelationships(session);
            createContributorToItemRelationships(session);
            createSubjectToItemRelationships(session);

            // Add more relationship creation methods as needed
        } catch (Exception e) {
            logger.error("An error occurred during the relationship creation process.", e);
        }

        logger.info("Relationship creation process completed.");
    }

    private static void createCallNumberToItemRelationships(Session session) {
        session.writeTransaction(new TransactionWork<Void>() {
            @Override
            public Void execute(Transaction tx) {
                tx.run("MATCH (c:CallNumber), (i:Item) " +
                       "WHERE c.externalId = i.callNumber " +
                       "CREATE (c)-[:ASSOCIATED_WITH]->(i)");
                logger.info("Created relationships between CallNumbers and Items based on external_id.");
                return null;
            }
        });
    }

    private static void createResourceToItemRelationships(Session session) {
        session.writeTransaction(new TransactionWork<Void>() {
            @Override
            public Void execute(Transaction tx) {
                tx.run("MATCH (r:Resource), (i:Item) " +
                       "WHERE r.externalId = i.externalId " +
                       "CREATE (r)-[:RESOURCE_OF]->(i)");
                logger.info("Created relationships between Resources and Items based on external_id.");
                return null;
            }
        });
    }

    private static void createContributorToItemRelationships(Session session) {
        session.writeTransaction(new TransactionWork<Void>() {
            @Override
            public Void execute(Transaction tx) {
                tx.run("MATCH (c:Contributor), (i:Item) " +
                       "WHERE c.externalId = i.externalId " +
                       "CREATE (c)-[:CONTRIBUTED_TO]->(i)");
                logger.info("Created relationships between Contributors and Items based on external_id.");
                return null;
            }
        });
    }

    private static void createSubjectToItemRelationships(Session session) {
        session.writeTransaction(new TransactionWork<Void>() {
            @Override
            public Void execute(Transaction tx) {
                tx.run("MATCH (s:Subject), (i:Item) " +
                       "WHERE s.externalId = i.externalId " +
                       "CREATE (s)-[:SUBJECT_OF]->(i)");
                logger.info("Created relationships between Subjects and Items based on external_id.");
                return null;
            }
        });
    }

    public static void main(String[] args) {
        createRelationships();
        Neo4jConnection.close();
    }
}

```



### Step 9: Compile and Run the workflowProgram

To compile and run the relationship creation program, use the following commands:

```sh
cd supreme-court-transfer
mvn compile
mvn exec:java -Dexec.mainClass="com.supreme_court_transfer.App"
mvn exec:java -Dexec.mainClass="com.supreme_court_transfer.RelationshipCreator" 
```

 
