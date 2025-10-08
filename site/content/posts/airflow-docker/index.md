+++
title =  "Airflow + Neo4j DAG"
description = "Deploying Airflow and a NEO4j Dag"
tags = ['java', "postgresql","cdp"]
images = ["images/feature-image.png"]
date = "2024-08-9T14:25:13-05:00"
categories = ["projects"]
series = ["java", "supreme-court"]
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


# Running Apache Airflow with Docker: Deploy A Neo4j Workflow


Apache Airflow is a powerful tool for orchestrating complex workflows, and running it with Docker simplifies the setup and maintenance of the environment. In this guide, we will walk through setting up Apache Airflow using Docker, making sure that any changes to your DAGs (Directed Acyclic Graphs) are immediately reflected in the running environment.

Though, I really don't think I'll use it. I feel like for my use cases it is better to just use GCP cloud run jobs. 



## Prerequisites

Before we begin, make sure you have the following installed:

Docker
Docker Compose


### Step 1: Setting Up Your Project

First, create a directory for your Airflow project. Inside this directory, create the necessary subdirectories and files.

```bash
mkdir airflow-docker
cd airflow-docker
mkdir dags logs plugins
touch dags/example_dag.py
touch docker-compose.yml
Step 2: Creating the docker-compose.yml File
The docker-compose.yml file defines the services, volumes, and networks required to run Airflow. Below is a sample configuration:

yaml
Copy code
version: '3.8'

services:
  postgres:
    image: postgres:13
    environment:
      POSTGRES_USER: airflow
      POSTGRES_PASSWORD: airflow
      POSTGRES_DB: airflow
    ports:
      - "5438:5432"
    volumes:
      - postgres-db-volume:/var/lib/postgresql/data

  redis:
    image: redis:6.2
    ports:
      - "6379:6379"

  airflow-init:
    image: apache/airflow:2.3.0
    entrypoint: >
      bash -c "
      airflow db upgrade &&
      airflow users create -r Admin -u admin -p admin -e admin@example.com -f Admin -l User
      "
    environment:
      - AIRFLOW__CORE__FERNET_KEY=k37aZADrVkqzK7fed8xTjphUGlT3LtFzr9uUMtnRwmg=
      - AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=postgresql+psycopg2://airflow:airflow@postgres/airflow
    volumes:
      - ./dags:/opt/airflow/dags
      - ./logs:/opt/airflow/logs
      - ./plugins:/opt/airflow/plugins
    depends_on:
      - postgres
      - redis

  airflow-webserver:
    image: apache/airflow:2.3.0
    command: webserver
    ports:
      - "8089:8080"
    environment:
      - AIRFLOW__CORE__FERNET_KEY=k37aZADrVkqzK7fed8xTjphUGlT3LtFzr9uUMtnRwmg=
      - AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=postgresql+psycopg2://airflow:airflow@postgres/airflow
    volumes:
      - ./dags:/opt/airflow/dags
      - ./logs:/opt/airflow/logs
      - ./plugins:/opt/airflow/plugins
    depends_on:
      - airflow-init

  airflow-scheduler:
    image: apache/airflow:2.3.0
    command: scheduler
    environment:
      - AIRFLOW__CORE__FERNET_KEY=k37aZADrVkqzK7fed8xTjphUGlT3LtFzr9uUMtnRwmg=
      - AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=postgresql+psycopg2://airflow:airflow@postgres/airflow
    volumes:
      - ./dags:/opt/airflow/dags
      - ./logs:/opt/airflow/logs
      - ./plugins:/opt/airflow/plugins
    depends_on:
      - airflow-init

  airflow-worker:
    image: apache/airflow:2.3.0
    command: celery worker
    environment:
      - AIRFLOW__CORE__FERNET_KEY=k37aZADrVkqzK7fed8xTjphUGlT3LtFzr9uUMtnRwmg=
      - AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=postgresql+psycopg2://airflow:airflow@postgres/airflow
    volumes:
      - ./dags:/opt/airflow/dags
      - ./logs:/opt/airflow/logs
      - ./plugins:/opt/airflow/plugins
    depends_on:
      - airflow-init

volumes:
  postgres-db-volume:

```

### Step 3: Creating a Sample DAG

Next, create a simple DAG in the dags directory to test your setup. This example will create a DAG that simply runs two dummy tasks.

```python

# dags/example_dag.py
from airflow import DAG
from airflow.operators.dummy_operator import DummyOperator
from datetime import datetime

default_args = {
    'owner': 'airflow',
    'start_date': datetime(2023, 1, 1),
    'retries': 1,
}

with DAG('example_dag', default_args=default_args, schedule_interval='@daily') as dag:
    start = DummyOperator(task_id='start')
    end = DummyOperator(task_id='end')

    start >> end

```


### Step 4: Running Docker Compose

With everything set up, you can now build and run your Airflow environment using Docker Compose.

```bash

docker-compose up --build
```

### Step 5: Accessing the Airflow Web Interface

Once the services are up and running, you can access the Airflow web interface by navigating to http://localhost:8089 in your web browser. Log in with the credentials you specified in the airflow-init service (admin/admin).

### Step 6: Modifying DAGs

You can freely modify your DAGs in the dags directory on your local machine. These changes will be automatically reflected in the running Airflow environment due to the volume mount configuration.


### Step 7: Orchestrate a Neo4j Workflow 

I created a quick neo4j workflow for some reference.

```python

from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from datetime import datetime
from neo4j import GraphDatabase
import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv('/opt/airflow/.env')  # Path within the Docker container

# Define Neo4j connection details from environment variables
NEO4J_URL = os.getenv('NEO4J_URL')
NEO4J_USER = os.getenv('NEO4J_USER')
NEO4J_PASSWORD = os.getenv('NEO4J_PASSWORD')

def read_query_file(filepath):
    with open(filepath, 'r') as file:
        query = file.read()
    return query

# Function for creating relationships between contributors and subjects
def make_contributor_to_subject_relationships():
    driver = GraphDatabase.driver(NEO4J_URL, auth=(NEO4J_USER, NEO4J_PASSWORD))
    cypher_query = read_query_file('/opt/airflow/sql/ctrbr_to_sbjt.cql')  # Path within the Docker container

    def execute_query(tx):
        result = tx.run(cypher_query)
        for record in result:
            print(record)

    with driver.session() as session:
        session.write_transaction(execute_query)
    driver.close()

default_args = {
    'owner': 'airflow',
    'start_date': datetime(2024, 8, 9),
    'retries': 1,
}

dag = DAG('neo4j_workflow', default_args=default_args, schedule_interval='@daily')

# Placeholder functions for future use
# def ingest_data():
#     sql_query = read_query_file('/opt/airflow/sql/ingest_data.sql')  # Path within the Docker container
#     # Execute your SQL query here using your database connection
#     print(sql_query)  # Replace this with actual query execution logic

# def transform_data():
#     sql_query = read_query_file('/opt/airflow/sql/transform_data.sql')  # Path within the Docker container
#     # Execute your SQL query here using your database connection
#     print(sql_query)  # Replace this with actual query execution logic

# Define the task for making contributor-to-subject relationships
t3 = PythonOperator(
    task_id='make_contributor_to_subject_relationships',
    python_callable=make_contributor_to_subject_relationships,
    dag=dag
)

# Define the DAG structure
t3

```



## Reference Repository
For a complete example with all the necessary files, you can refer to the airflow-docker-example repository. Clone this repository to get started quickly.

```bash

git clone https://github.com/justin-napolitano/airflow-docker.git
cd airflow-docker
docker-compose up --build

```

Conclusion
Running Apache Airflow with Docker simplifies the setup and allows you to develop and test your workflows efficiently.That said, I prefer gcp cloud run. I think provisioning a managed version in google could be worth it for a large organization.. but for my personal projects gcp is the way to go. 

