+++
title =  "Postgres to Neo4j Workflow: Relationships"
description = "Streamlining Data Transfer from PostgreSQL to Neo4j with Java... With Relationships Between Nodes"
tags = ['python', "neo4j","databases"]
images = ["images/feature-image.png"]
date = "2024-08-06T16:10:02-05:00"
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


# Updating the PostGres to Neo workflow with Standard Meta Data Relationships

In my previous post i detailed how to export data from postgresql to neo4j with a java workflow.. but I did not add how add relationships once the node insert completes. 


Here is the repo btw ```https://github.com/justin-napolitano/supreme-court-transfer```

## RelationshipCreator.java 

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

### Build and Execute

```bash
cd supreme-court-transfer
mvn compile
mvn exec:java -Dexec.mainClass="com.supreme_court_transfer.App"
mvn exec:java -Dexec.mainClass="com.supreme_court_transfer.RelationshipCreator" 
```
