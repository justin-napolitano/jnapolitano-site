+++
title =  "PostgreSQL to Neo4j Transfer: Unique Nodes and DB Optimization"
description = "Optimizing Graph Databases: Ensuring Unique Nodes and Creating Efficient Relationships in Neo4j"
tags = ['java', "neo4j","databases"]
images = ["images/feature-image.png"]
date = "2024-08-07T14:59:58-05:00"
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


# Optimizing Graph Databases: Ensuring Unique Nodes and Creating Efficient Relationships in Neo4j

repo source : ```https://github.com/justin-napolitano/supreme-court-transfer```

In my last post I kinda messed up.. well not really but I did not account for trying to create unique relationships.. That doesn't really matter though because my postgres db is normalized.. so i can make those relationships easy.  This post details how to do that. 

## Importance of Normalization

When working with large datasets, particularly in a relational database, ensuring the uniqueness of nodes and creating efficient relationships in a graph database like Neo4j can be challenging. This post will discuss how I approached this problem while building a graph from a PostgreSQL database containing Supreme Court case metadata. By ensuring a normalized source of truth, I optimized queries for building an effective and accurate graph.

## The Challenge of Non-Unique Nodes

In relational databases, data is often stored in multiple tables with foreign keys linking related data. When importing this data into a graph database, it’s crucial to ensure that each node represents a unique entity. Without this, you can end up with duplicate nodes, leading to an inaccurate and inefficient graph.

For example, consider the following tables:

items: Contains metadata about Supreme Court cases.
callnumbers: Contains call numbers associated with cases.
contributors: Contains contributors to the cases.
resources: Contains resources like PDFs and images associated with cases.
subjects: Contains subjects associated with cases.

Each of these tables may reference the same external_id, representing a unique case. To avoid creating duplicate nodes in Neo4j, we need to ensure that each node is truly unique.

### Step 1: Ensuring Unique Nodes

To ensure the uniqueness of nodes, I first created nodes for each entity type with the relevant metadata. Here’s a simplified example of how this was done for each table:

#### Item Node

```java
public static void insertItemsIntoNeo4j(Set<Item> items) {
    Session neo4jSession = Neo4jConnection.getSession();
    for (Item item : items) {
        neo4jSession.run("MERGE (i:Item {externalId: $externalId}) " +
                        "ON CREATE SET i.title = $title, i.callNumber = $callNumber, i.date = $date",
                Values.parameters(
                        "externalId", item.getExternalId(),
                        "title", item.getTitle() != null ? item.getTitle() : "",
                        "callNumber", item.getCallNumber() != null ? item.getCallNumber() : "",
                        "date", item.getDate() != null ? item.getDate() : ""
                ));
    }
    neo4jSession.close();
    logger.info("Inserted {} unique items into Neo4j.", items.size());
}
```

#### Call Number Node

```java

public static void insertCallNumbersIntoNeo4j(Set<CallNumber> callNumbers) {
    Session neo4jSession = Neo4jConnection.getSession();
    for (CallNumber callNumber : callNumbers) {
        neo4jSession.run("MERGE (c:CallNumber {externalId: $externalId}) " +
                        "ON CREATE SET c.callNumber = $callNumber",
                Values.parameters(
                        "externalId", callNumber.getExternalId(),
                        "callNumber", callNumber.getCallNumber() != null ? callNumber.getCallNumber() : ""
                ));
    }
    neo4jSession.close();
    logger.info("Inserted {} unique call numbers into Neo4j.", callNumbers.size());
}

```

#### Contributor Node

For contributors and subjects, we did not use externalId to ensure that each contributor and subject node is unique based on their properties alone.

```java

public static void insertContributorsIntoNeo4j(Set<Contributor> contributors) {
    Session neo4jSession = Neo4jConnection.getSession();
    for (Contributor contributor : contributors) {
        neo4jSession.run("MERGE (c:Contributor {contributor: $contributor})",
                Values.parameters(
                        "contributor", contributor.getContributor() != null ? contributor.getContributor() : ""
                ));
    }
    neo4jSession.close();
    logger.info("Inserted {} unique contributors into Neo4j.", contributors.size());
}

```
### Step 2: Creating Relationships

After ensuring that nodes were unique, the next step was to create relationships between these nodes based on the join results from the PostgreSQL database. This step involves querying the relational database to join the relevant tables and then creating relationships in Neo4j.

#### Example: Relating Items to Subjects

```java

private static void relateItemsToSubjects(Session session, int limit) throws Exception {
    logger.info("Starting to relate items to subjects...");

    Connection postgresConn = PostgresConnection.getConnection();
    Statement stmt = postgresConn.createStatement();
    ResultSet rs = stmt.executeQuery("SELECT i.external_id, s.subject FROM items i LEFT JOIN subjects s ON i.external_id = s.external_id LIMIT " + limit);

    int count = 0;
    while (rs.next()) {
        String externalId = rs.getString("external_id");
        String subject = rs.getString("subject");

        if (subject != null) {
            session.writeTransaction((TransactionWork<Void>) tx -> {
                tx.run("MATCH (i:Item {externalId: $externalId}), (s:Subject {subject: $subject}) " +
                        "CREATE (i)-[:HAS_SUBJECT]->(s)",
                        Values.parameters(
                                "externalId", externalId,
                                "subject", subject
                        ));
                return null;
            });
            count++;
            logger.debug("Created relationship between Item (externalId: {}) and Subject (subject: {}).", externalId, subject);
        }
    }

    rs.close();
    stmt.close();
    postgresConn.close();
    logger.info("Related {} items to their subjects.", count);
}
```

### Running the Relationship Creator with a Limit

To facilitate testing with large tables, we added a limit argument to the relationship creation process, allowing us to specify how many records to process:

```sh

mvn compile
mvn exec:java -Dexec.mainClass="com.supreme_court_transfer.RelationshipCreator" -Dexec.args="100"

```

This command limits the number of records processed to 100, making it easier to test and debug the process with large datasets.

Conclusion
By ensuring a normalized source of truth and creating unique nodes in Neo4j, we optimized our graph database to accurately represent our relational data. This approach not only prevents the creation of non-unique nodes but also ensures efficient relationship creation based on actual data relationships.

This process highlights the importance of a normalized source of truth in relational databases when building graphs, allowing for optimized queries and accurate data representation in Neo4j. By carefully designing your data import and relationship creation processes, you can build powerful and efficient graph databases that leverage the strengths of both relational and graph data models.

This approach ensures that the graph database accurately reflects the relationships in the relational database, optimizing performance and maintaining data integrity.
