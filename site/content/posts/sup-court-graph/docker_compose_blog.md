+++
title =  "DataShare + Docker Compose"
date = "2024-07-29T16:12:27-05:00" 
description = "Deploying DataShare with Docker Compose"
author = "Jay Burd"
tags = ['python', "docker","graphs","graphdb","datashare","elasticsearch","Postgres","Redis"]
images = ["images/feature-python.png"]
categories = ["projects"]
series   = ["GCP"]
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


# Deploying DataShare with Docker Compose

Docker Compose is a powerful tool for defining and running multi-container Docker applications. In this blog post, we will walk through a Docker Compose script that sets up a comprehensive data sharing application stack, including DataShare, Elasticsearch, Redis, and PostgreSQL. This setup ensures seamless data management and sharing across different services.

## Overview of Services

The Docker Compose file defines the following services:
- **DataShare**: A powerful data sharing platform.
- **Elasticsearch**: A search and analytics engine.
- **Redis**: An in-memory data structure store.
- **PostgreSQL**: A robust relational database.

## Docker Compose File Breakdown

Here is the Docker Compose script we'll be discussing:

```yaml
version: "3.7"
services:

  datashare:
    image: icij/datashare:13.9.0
    hostname: datashare
    ports:
      - 8080:8080
    environment:
      - DS_DOCKER_MOUNTED_DATA_DIR=/home/datashare/data
    volumes:
      - type: bind
        source: ${HOME}/Datashare
        target: /home/datashare/data
      - type: volume
        source: datashare-models
        target: /home/datashare/dist
    command: >-
      --dataSourceUrl jdbc:postgresql://postgresql/datashare?user=datashare\&password=password 
      --mode LOCAL
      --tcpListenPort 8080
    depends_on:
      - postgresql
      - redis
      - elasticsearch

  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:7.9.1
    restart: on-failure
    volumes:
      - type: volume
        source: elasticsearch-data
        target: /usr/share/elasticsearch/data
        read_only: false
    environment:
      - "http.host=0.0.0.0"
      - "transport.host=0.0.0.0"
      - "cluster.name=datashare"
      - "discovery.type=single-node"
      - "discovery.zen.minimum_master_nodes=1"
      - "xpack.license.self_generated.type=basic"
      - "http.cors.enabled=true"
      - "http.cors.allow-origin=*"
      - "http.cors.allow-methods=OPTIONS, HEAD, GET, POST, PUT, DELETE"

  redis:
    image: redis:4.0.1-alpine
    restart: on-failure

  postgresql:
    image: postgres:12-alpine
    environment:
      - POSTGRES_USER=datashare
      - POSTGRES_PASSWORD=password
      - POSTGRES_DB=datashare
    volumes:
      - type: volume
        source: postgresql-data
        target: /var/lib/postgresql/data

volumes:
  datashare-models:
  elasticsearch-data:
  postgresql-data:
```

## Service Configuration Details

### DataShare

- **Image**: Uses the `icij/datashare:13.9.0` image.
- **Hostname**: Sets the hostname to `datashare`.
- **Ports**: Maps port 8080 on the host to port 8080 in the container.
- **Environment Variables**: Sets `DS_DOCKER_MOUNTED_DATA_DIR` to `/home/datashare/data`.
- **Volumes**:
  - Binds the host directory `${HOME}/Datashare` to `/home/datashare/data` in the container.
  - Mounts a Docker-managed volume `datashare-models` to `/home/datashare/dist`.
- **Command**: Configures the DataShare application to connect to PostgreSQL and operate in local mode.
- **Depends On**: Ensures that the `postgresql`, `redis`, and `elasticsearch` services are started before `datashare`.

### Elasticsearch

- **Image**: Uses `docker.elastic.co/elasticsearch/elasticsearch:7.9.1`.
- **Restart Policy**: Restarts the container on failure.
- **Volumes**: Uses a Docker-managed volume `elasticsearch-data` for data persistence.
- **Environment Variables**: Configures various Elasticsearch settings, including enabling CORS for HTTP.

### Redis

- **Image**: Uses `redis:4.0.1-alpine`.
- **Restart Policy**: Restarts the container on failure.

### PostgreSQL

- **Image**: Uses `postgres:12-alpine`.
- **Environment Variables**: Sets up the database with a user, password, and database name.
- **Volumes**: Uses a Docker-managed volume `postgresql-data` for data persistence.

## Volumes

The Compose file defines three Docker-managed volumes:
- **datashare-models**: Used by the `datashare` service.
- **elasticsearch-data**: Used by the `elasticsearch` service.
- **postgresql-data**: Used by the `postgresql` service.

## Running the Docker Compose Setup

To start the services defined in this Compose file, navigate to the directory containing the `docker-compose.yml` file and run:

```sh
docker-compose up -d
```

This command will download the necessary images (if not already present), create the containers, and start the services in detached mode.

## Conclusion

Using Docker Compose, we can efficiently manage and deploy a multi-container setup for a data sharing application. This setup includes DataShare, Elasticsearch, Redis, and PostgreSQL, ensuring robust data management and analytics capabilities.

For more detailed instructions and additional configurations, you can refer to the [official DataShare documentation](https://icij.gitbook.io/datashare/server-mode/install-with-docker).

With this setup, you can streamline your data sharing processes, enhance collaboration, and leverage the powerful search and analytics features provided by Elasticsearch, all within a manageable and scalable Docker environment.
