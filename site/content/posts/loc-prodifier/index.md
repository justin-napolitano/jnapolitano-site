+++
title =  "Library of Congress Prod-ifier"
#date = "2024-06-20 22:36:34.376 -0500" 
description = "Create a modular job to run in parallel to prod-ify a db "
author = "Justin Napolitano"
tags = ['python', "bigquery","programming","gcp"]
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



# Loc Prodifier

## Overview

Loc Prodifier is a Python script designed to merge data from staging tables into production tables in Google BigQuery without inserting duplicate records. It uses the Google Cloud BigQuery Python client and can be run both locally and in Google Cloud Run. The script is designed to be flexible and scalable, allowing for parallel execution across multiple tables using Google Cloud Workflows.

## Features

- Merges data from staging tables into production tables without duplicates.
- Supports parallel execution for multiple tables.
- Can be run locally with custom credentials or deployed in Google Cloud Run.
- Easily configurable through command-line arguments.

## Prerequisites

- Python 3.7 or higher
- Google Cloud SDK
- Docker
- A Google Cloud project with BigQuery and Cloud Run enabled
- Google Artifact Registry enabled in your Google Cloud project

## Installation

1. Clone the repository:

```sh
git clone https://github.com/justin-napolitano/loc_prodifier.git
cd loc_prodifier
```

2. Install the required Python packages:

```sh
pip install -r requirements.txt
```

## Usage

### Running Locally

To run the script locally, ensure you have your Google Cloud credentials JSON file and pass the required arguments:

```sh
python your_script.py --dataset_id your_dataset_id --staging_table_id your_staging_table_id --prod_table_id your_prod_table_id --local
```

### Running in Docker

1. Build the Docker image:

```sh
docker build -t my-bigquery-script .
```

2. Run the Docker container:

```sh
docker run --rm my-bigquery-script --dataset_id your_dataset_id --staging_table_id your_staging_table_id --prod_table_id your_prod_table_id --local
```

### Deploying to Google Cloud Run

1. Create the \`cloudrun.yaml\` file:

```yaml
steps:
  # Step 1: Create the Artifact Registry repository if it doesn't exist
  - name: 'gcr.io/cloud-builders/gcloud'
    entrypoint: 'bash'
    args:
      - '-c'
      - |
        if ! gcloud artifacts repositories describe python-loc-prodifier --location=us-west2 > /dev/null 2>&1; then
          gcloud artifacts repositories create python-loc-prodifier --repository-format=docker --location=us-west2
        else
          echo "Repository python-loc-prodifier already exists"
        fi

  # Step 2: Build the Docker image
  - name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-t', 'us-west2-docker.pkg.dev/smart-axis-421517/python-loc-prodifier/python-loc-prodifier:dev', '.']

  # Step 3: Push the Docker image to Artifact Registry
  - name: 'gcr.io/cloud-builders/docker'
    args: ['push', 'us-west2-docker.pkg.dev/smart-axis-421517/python-loc-prodifier/python-loc-prodifier:dev']

  # Step 4: Create the Cloud Run job
  - name: 'gcr.io/cloud-builders/gcloud'
    args: [
      'run', 'jobs', 'create', 'python-loc-prodifier-job',
      '--image', 'us-west2-docker.pkg.dev/smart-axis-421517/python-loc-prodifier/python-loc-prodifier:dev',
      '--region', 'us-west2'
    ]

images:
  - 'us-west2-docker.pkg.dev/smart-axis-421517/python-loc-prodifier/python-loc-prodifier:dev'
```

2. Submit the build:

```sh
gcloud builds submit --config cloudrun.yaml .
```

3. Execute the Cloud Run job:

```sh
gcloud run jobs execute python-loc-prodifier-job --region us-west2
```

4. Check logs for job execution:

```sh
gcloud logging read "resource.type=cloud_run_job AND resource.labels.job_name=python-loc-prodifier-job" --limit 50
```

### Running with Google Cloud Workflows

To execute the script for multiple tables in parallel using Google Cloud Workflows:

1. Create the \`workflow.yaml\` file:

```yaml
main:
  params: [dataset_id, tables, staging_table_suffix, prod_table_suffix]
  steps:
  - parallel:
      steps:
      - parallel_task:
          call: http.post
          args:
            url: "https://your-region-run.googleapis.com/v1/projects/your_project_id/locations/your-region/services/my-bigquery-script:run"
            headers:
              Authorization: "Bearer $(ref(auth.access_token))"
            body:
              dataset_id: ${dataset_id}
              staging_table_id: ${table}.staging
              prod_table_id: ${table}.prod
          each:
            - table: ${tables}
  - return: "Workflow executed"

auth:
  steps:
  - get_token:
      call: google.auth.access_token
```

2. Deploy the workflow:

```sh
gcloud workflows deploy my-bigquery-workflow --source=workflow.yaml --location=your-region
```

3. Execute the workflow:

```sh
gcloud workflows execute my-bigquery-workflow --location=your-region --data='{
  "dataset_id": "your_dataset_id",
  "tables": ["table1", "table2", "table3"],
  "staging_table_suffix": "staging",
  "prod_table_suffix": "prod"
}'
```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Google Cloud BigQuery](https://cloud.google.com/bigquery)
- [Google Cloud Run](https://cloud.google.com/run)
- [Google Cloud Workflows](https://cloud.google.com/workflows)
