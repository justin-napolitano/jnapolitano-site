+++
title =  "GCP Cloud Run: LOC Flattener"
date = "2024-07-11"
description = "Flattening and injesting JSON into data lake.. Autonomously. "
author = "Justin Napolitano"
tags = ['git', 'python', 'gcp', 'bash','workflow automation', 'docker','containerization']
images = ["images/feature-gcp.png"]
categories = ["projects"]
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


# Library of Congress Normalizer Job

This [repo](https://github.com/justin-napolitano/loc_normalizer) normalizes the existing library of congress schema into a db that wil then be used to construct a knowledge graph of supreme court law. 

## Plan

1. Setup a venv to run locally
2. Install requirements
3. Write out the script to interface with gcp
4. Set up a docker container and test locally
5. build the image
6. upload to gcp
7. create the job

## Setup the venv

### Install
I installed virtualenv locally on ubuntu

### Create
I then run ```virtualenv {path to venvs}```

### Activate

Then source the venv bin to activate

```source {path to venv}/bin/activate```
   
### Install requirements

``` pip install -r requirements.txt```

## Write out the Script

### Steps

1. Access the loc_scraper Bucket
2. Grab a json blob
3. Process the blob
4. Move the blob to a processed bucket


### Data Organization

I want to create workflow class with the following methods

1. get_creds
2. grab_blob
3. process_blob
4. move_blob

The process_blob method will be a lot of work.  I might just flatten the json and dump into a table. I will then write a normalization workflow


### Get Creds

If running locally I will need some creds in the enviornment. I will take create a key from the console and download it for local run . 








## Setup the Docker Container

### The Dockerfile

Also available on [github](https://github.com/justin-napolitano/loc_normalizer/blob/main/Dockerfile)


```
# # Use the Alpine Linux base image
# FROM alpine:latest

# # Set the working directory inside the container
# WORKDIR /app

# # Copy a simple script that prints "Hello, World!" into the container
# COPY /src/hello.sh .

# # Make the script executable
# RUN chmod +x hello.sh

# # Define the command to run when the container starts
# CMD ["./hello.sh"]


# Use the official Python image from Docker Hub
FROM python:3.10-slim

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY ./src /app
COPY requirements.txt /app

# Install any needed dependencies specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Run the Python script when the container launches
CMD ["python", "loc_scraper.py"]
```


## Quickstart


### Gcloud cli
After this you will have to install gcloud cli and configure you're local environment. I will write up some scripts in a subsequent post to automate this process... but for the time being check out this ["link"](https://cloud.google.com/sdk/docs/install)

### Create the image

In the repo there is a a bash script called ```build.sh``` that will need to be updated to according to your gcp project.

```bash
gcloud builds submit --region=us-west2 --config cloudbuild.yaml
```

It calls ```cloudbuild.yaml``` which might need to be updated for you, but the following the should work.

```yaml
steps:
- name: 'gcr.io/cloud-builders/docker'
  script: |
    docker build -t us-west2-docker.pkg.dev/$PROJECT_ID/supreme-court-scraper/supreme-court-scraper-image:dev .
  automapSubstitutions: true
images:
- 'us-west2-docker.pkg.dev/$PROJECT_ID/supreme-court-scraper/supreme-court-scraper-image:dev'
```

### Following creation of the imge 
Next you can create a job on gcp by runnning the ```job_create.sh``` script... or by copying the code below and chaging yourproject to the correct project-name

```bash
gcloud run jobs create supreme-court-scraper --image us-west2-docker.pkg.dev/yourproject/supreme-court-scraper/supreme-court-scraper-image:dev \
```

### Executing the job

Once complete you can execute the job by running the ```execute_job.sh``` script or by running 

```bash
gcloud run jobs execute supreme-court-scraper
```

### Putting it all together

In a perfect world the following should work. Note that src/.env should be set with your environmental variables such as ```$GCPPROJECTID``` 

```bash
source src/.env \
&& ./build.sh \ 
&& ./job_create.sh \
&& ./execute_job.sh
```

## Running locally

The python script in the ```/src``` can be run locally, however it should be modified if you choose not to use gcp.  There are a number of functions within that can easily be modified to permit writing to the local directory. 


## Documentation Sources
1. ["Google Cloud Run Jobs Automation"](https://cloud.google.com/run/docs/create-jobs)



```python
pip install -r ../requirements.txt
```

    Requirement already satisfied: beautifulsoup4==4.12.3 in /home/cobra/.config/jupyterlab-desktop/jlab_server/lib/python3.12/site-packages (from -r ../requirements.txt (line 1)) (4.12.3)
    Requirement already satisfied: bs4==0.0.2 in /home/cobra/.config/jupyterlab-desktop/jlab_server/lib/python3.12/site-packages (from -r ../requirements.txt (line 2)) (0.0.2)
    Requirement already satisfied: cachetools==5.3.3 in /home/cobra/.config/jupyterlab-desktop/jlab_server/lib/python3.12/site-packages (from -r ../requirements.txt (line 3)) (5.3.3)
    Requirement already satisfied: certifi==2024.2.2 in /home/cobra/.config/jupyterlab-desktop/jlab_server/lib/python3.12/site-packages (from -r ../requirements.txt (line 4)) (2024.2.2)
    Requirement already satisfied: charset-normalizer==3.3.2 in /home/cobra/.config/jupyterlab-desktop/jlab_server/lib/python3.12/site-packages (from -r ../requirements.txt (line 5)) (3.3.2)
    Requirement already satisfied: flatten-json==0.1.14 in /home/cobra/.config/jupyterlab-desktop/jlab_server/lib/python3.12/site-packages (from -r ../requirements.txt (line 6)) (0.1.14)
    Requirement already satisfied: google-api-core==2.18.0 in /home/cobra/.config/jupyterlab-desktop/jlab_server/lib/python3.12/site-packages (from -r ../requirements.txt (line 7)) (2.18.0)
    Requirement already satisfied: google-auth==2.29.0 in /home/cobra/.config/jupyterlab-desktop/jlab_server/lib/python3.12/site-packages (from -r ../requirements.txt (line 8)) (2.29.0)
    Requirement already satisfied: google-cloud-appengine-logging==1.4.3 in /home/cobra/.config/jupyterlab-desktop/jlab_server/lib/python3.12/site-packages (from -r ../requirements.txt (line 9)) (1.4.3)
    Requirement already satisfied: google-cloud-audit-log==0.2.5 in /home/cobra/.config/jupyterlab-desktop/jlab_server/lib/python3.12/site-packages (from -r ../requirements.txt (line 10)) (0.2.5)
    Requirement already satisfied: google-cloud-core==2.4.1 in /home/cobra/.config/jupyterlab-desktop/jlab_server/lib/python3.12/site-packages (from -r ../requirements.txt (line 11)) (2.4.1)
    Requirement already satisfied: google-cloud-logging==3.10.0 in /home/cobra/.config/jupyterlab-desktop/jlab_server/lib/python3.12/site-packages (from -r ../requirements.txt (line 12)) (3.10.0)
    Requirement already satisfied: google-cloud-storage==2.16.0 in /home/cobra/.config/jupyterlab-desktop/jlab_server/lib/python3.12/site-packages (from -r ../requirements.txt (line 13)) (2.16.0)
    Requirement already satisfied: google-crc32c==1.5.0 in /home/cobra/.config/jupyterlab-desktop/jlab_server/lib/python3.12/site-packages (from -r ../requirements.txt (line 14)) (1.5.0)
    Requirement already satisfied: google-resumable-media==2.7.0 in /home/cobra/.config/jupyterlab-desktop/jlab_server/lib/python3.12/site-packages (from -r ../requirements.txt (line 15)) (2.7.0)
    Requirement already satisfied: googleapis-common-protos==1.63.0 in /home/cobra/.config/jupyterlab-desktop/jlab_server/lib/python3.12/site-packages (from -r ../requirements.txt (line 16)) (1.63.0)
    Requirement already satisfied: grpc-google-iam-v1==0.13.0 in /home/cobra/.config/jupyterlab-desktop/jlab_server/lib/python3.12/site-packages (from -r ../requirements.txt (line 17)) (0.13.0)
    Requirement already satisfied: grpcio==1.62.2 in /home/cobra/.config/jupyterlab-desktop/jlab_server/lib/python3.12/site-packages (from -r ../requirements.txt (line 18)) (1.62.2)
    Requirement already satisfied: grpcio-status==1.62.2 in /home/cobra/.config/jupyterlab-desktop/jlab_server/lib/python3.12/site-packages (from -r ../requirements.txt (line 19)) (1.62.2)
    Requirement already satisfied: idna==3.7 in /home/cobra/.config/jupyterlab-desktop/jlab_server/lib/python3.12/site-packages (from -r ../requirements.txt (line 20)) (3.7)
    Requirement already satisfied: proto-plus==1.23.0 in /home/cobra/.config/jupyterlab-desktop/jlab_server/lib/python3.12/site-packages (from -r ../requirements.txt (line 21)) (1.23.0)
    Requirement already satisfied: protobuf==4.25.3 in /home/cobra/.config/jupyterlab-desktop/jlab_server/lib/python3.12/site-packages (from -r ../requirements.txt (line 22)) (4.25.3)
    Requirement already satisfied: pyasn1==0.6.0 in /home/cobra/.config/jupyterlab-desktop/jlab_server/lib/python3.12/site-packages (from -r ../requirements.txt (line 23)) (0.6.0)
    Requirement already satisfied: pyasn1_modules==0.4.0 in /home/cobra/.config/jupyterlab-desktop/jlab_server/lib/python3.12/site-packages (from -r ../requirements.txt (line 24)) (0.4.0)
    Requirement already satisfied: requests==2.31.0 in /home/cobra/.config/jupyterlab-desktop/jlab_server/lib/python3.12/site-packages (from -r ../requirements.txt (line 25)) (2.31.0)
    Requirement already satisfied: rsa==4.9 in /home/cobra/.config/jupyterlab-desktop/jlab_server/lib/python3.12/site-packages (from -r ../requirements.txt (line 26)) (4.9)
    Requirement already satisfied: six==1.16.0 in /home/cobra/.config/jupyterlab-desktop/jlab_server/lib/python3.12/site-packages (from -r ../requirements.txt (line 27)) (1.16.0)
    Requirement already satisfied: soupsieve==2.5 in /home/cobra/.config/jupyterlab-desktop/jlab_server/lib/python3.12/site-packages (from -r ../requirements.txt (line 28)) (2.5)
    Requirement already satisfied: urllib3==2.2.1 in /home/cobra/.config/jupyterlab-desktop/jlab_server/lib/python3.12/site-packages (from -r ../requirements.txt (line 29)) (2.2.1)
    Requirement already satisfied: google-cloud-bigquery==3.25.0 in /home/cobra/.config/jupyterlab-desktop/jlab_server/lib/python3.12/site-packages (from -r ../requirements.txt (line 40)) (3.25.0)
    Collecting numpy==2.0.0 (from -r ../requirements.txt (line 51))
      Downloading numpy-2.0.0-cp312-cp312-manylinux_2_17_x86_64.manylinux2014_x86_64.whl.metadata (60 kB)
    [2K     [38;2;114;156;31m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[0m [32m60.9/60.9 kB[0m [31m1.1 MB/s[0m eta [36m0:00:00[0m[31m1.1 MB/s[0m eta [36m0:00:01[0m
    [?25hCollecting packaging==24.1 (from -r ../requirements.txt (line 52))
      Downloading packaging-24.1-py3-none-any.whl.metadata (3.2 kB)
    Requirement already satisfied: pandas==2.2.2 in /home/cobra/.config/jupyterlab-desktop/jlab_server/lib/python3.12/site-packages (from -r ../requirements.txt (line 53)) (2.2.2)
    Requirement already satisfied: pyarrow==16.1.0 in /home/cobra/.config/jupyterlab-desktop/jlab_server/lib/python3.12/site-packages (from -r ../requirements.txt (line 56)) (16.1.0)
    Collecting python-dateutil==2.9.0.post0 (from -r ../requirements.txt (line 59))
      Downloading python_dateutil-2.9.0.post0-py2.py3-none-any.whl.metadata (8.4 kB)
    Requirement already satisfied: pytz==2024.1 in /home/cobra/.config/jupyterlab-desktop/jlab_server/lib/python3.12/site-packages (from -r ../requirements.txt (line 60)) (2024.1)
    Requirement already satisfied: tzdata==2024.1 in /home/cobra/.config/jupyterlab-desktop/jlab_server/lib/python3.12/site-packages (from -r ../requirements.txt (line 65)) (2024.1)
    Downloading numpy-2.0.0-cp312-cp312-manylinux_2_17_x86_64.manylinux2014_x86_64.whl (19.0 MB)
    [2K   [38;2;114;156;31m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[0m [32m19.0/19.0 MB[0m [31m2.2 MB/s[0m eta [36m0:00:00[0mm eta [36m0:00:01[0m[36m0:00:01[0m
    [?25hDownloading packaging-24.1-py3-none-any.whl (53 kB)
    [2K   [38;2;114;156;31m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[0m [32m54.0/54.0 kB[0m [31m1.7 MB/s[0m eta [36m0:00:00[0m
    [?25hDownloading python_dateutil-2.9.0.post0-py2.py3-none-any.whl (229 kB)
    [2K   [38;2;114;156;31m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[0m [32m229.9/229.9 kB[0m [31m2.3 MB/s[0m eta [36m0:00:00[0m MB/s[0m eta [36m0:00:01[0m
    [?25hInstalling collected packages: python-dateutil, packaging, numpy
      Attempting uninstall: python-dateutil
        Found existing installation: python-dateutil 2.9.0
        Uninstalling python-dateutil-2.9.0:
          Successfully uninstalled python-dateutil-2.9.0
      Attempting uninstall: packaging
        Found existing installation: packaging 24.0
        Uninstalling packaging-24.0:
          Successfully uninstalled packaging-24.0
      Attempting uninstall: numpy
        Found existing installation: numpy 1.26.4
        Uninstalling numpy-1.26.4:
          Successfully uninstalled numpy-1.26.4
    Successfully installed numpy-2.0.0 packaging-24.1 python-dateutil-2.9.0.post0
    Note: you may need to restart the kernel to use updated packages.


## Write out the Script

### Steps
1. Initialize the Google Logging Service
2. Initialize The Google Cloud Storage Service
1. Initialize the Bigquery Client
2. Grab a json blob
3. Process the blob
4. Move the blob to a processed bucket


#### Initialize The Google Cloud Storage Service

I created a Gloud Service Client Class available at : https://github.com/justin-napolitano/gcputils/blob/bc421debf4c828522580ec79ab634b2e2bf402a4/GoogleCloudLogging.py

It is imported below and tested below.  Note that cli specific arguments are commented out for testing in ipynb. 


```python
# loc_flattener.py
# library_of_congress_scraper.py

from __future__ import print_function
from gcputils.gcpclient import GCSClient
from gcputils.GoogleCloudLogging import GoogleCloudLogging
from gcputils.BigQueryClient import BigQueryClient
from bs4 import BeautifulSoup
import requests
import json
import os
import time
from pprint import pprint
import html
from flatten_json import flatten
import google.cloud.logging
import logging
import argparse
import pandas as pd
from google.cloud import bigquery
```


```python

def initialize_google_cloud_logging_client(project_id, credentials_path=None):
    return GoogleCloudLogging(project_id, credentials_path=credentials_path)


def main():
    # parser = argparse.ArgumentParser(description='Run the script locally or in the cloud.')
    # parser.add_argument('--local', action='store_true', help='Run the script locally with credentials path')
    # args = parser.parse_args()

    project_id = os.getenv('GCP_PROJECT_ID', 'smart-axis-421517')
    bucket_name = os.getenv('BUCKET_NAME', 'loc-scraper')

    credentials_path = None
    # if args.local:
    credentials_path = os.getenv('GCP_CREDENTIALS_PATH', 'secret.json')

    # Initialize logging
    logging_client = initialize_google_cloud_logging_client(project_id,credentials_path)
    logging_client.setup_logging()


if __name__ == "__main__":
    main()
```

#### Initialize the Google Cloud Storage Client

The Google Cloud Storage Client is available at https://github.com/justin-napolitano/gcputils/blob/bc421debf4c828522580ec79ab634b2e2bf402a4/gcpclient.py

Calling the client and listing the buckets to test below


```python

def initialize_google_cloud_logging_client(project_id, credentials_path=None):
    return GoogleCloudLogging(project_id, credentials_path=credentials_path)

def initialize_gcs_client(project_id, credentials_path=None):
    return GCSClient(project_id, credentials_path=credentials_path)

def list_gcs_buckets(client):
    try:
        buckets = client.list_buckets()
        print("Buckets:", buckets)
        logging.info(f"Buckets: {buckets}")
    except Exception as e:
        logging.error(f"Error listing buckets: {e}")

def main():
    # parser = argparse.ArgumentParser(description='Run the script locally or in the cloud.')
    # parser.add_argument('--local', action='store_true', help='Run the script locally with credentials path')
    # args = parser.parse_args()

    project_id = os.getenv('GCP_PROJECT_ID', 'smart-axis-421517')
    bucket_name = os.getenv('BUCKET_NAME', 'loc-scraper')

    credentials_path = None
    # if args.local:
    credentials_path = os.getenv('GCP_CREDENTIALS_PATH', 'secret.json')

    # Initialize logging
    logging_client = initialize_google_cloud_logging_client(project_id,credentials_path)
    logging_client.setup_logging()

    gcs_client = initialize_gcs_client(project_id, credentials_path)
    list_gcs_buckets(gcs_client)


if __name__ == "__main__":
    main()
```

    trying creds file
    Buckets: ['loc-scraper', 'loc_flattener_processed', 'processed_results', 'smart-axis-421517_cloudbuild']


#### Access the Blobs within the bucket

Now I need to grab a blob from the bucket. IN this case I just want to grab one from the top of the heap without pulling a lot of data into context. 

##### Addition to the storage class 

```Python

def list_blobs(self, bucket_name):
        """
        Lists all blobs in the specified bucket in Google Cloud Storage.

        Args:
            bucket_name (str): Name of the bucket.

        Returns:
            list: A list of blob names.
        """
        # Get the bucket
        bucket = self.client.bucket(bucket_name)
        
        # List all blobs in the bucket
        blobs = list(bucket.list_blobs())
        
        blob_names = [blob.name for blob in blobs]
        return blob_names

def pop_blob(self, bucket_name):
        """
        Selects and removes the first blob from the specified bucket in Google Cloud Storage.

        Args:
            bucket_name (str): Name of the bucket.

        Returns:
            google.cloud.storage.blob.Blob: The first blob from the bucket.
        """
        # Get the bucket
        bucket = self.client.bucket(bucket_name)
        
        # List all blobs in the bucket
        blobs = list(bucket.list_blobs())
        
        if not blobs:
            print(f"No blobs found in bucket '{bucket_name}'.")
            return None

        # Get the first blob
        first_blob = blobs[0]
        
        print(f"First blob selected: {first_blob.name}")
        return first_blob

```

##### Test Run 


```python
def initialize_google_cloud_logging_client(project_id, credentials_path=None):
    return GoogleCloudLogging(project_id, credentials_path=credentials_path)

def initialize_gcs_client(project_id, credentials_path=None):
    return GCSClient(project_id, credentials_path=credentials_path)

def list_gcs_buckets(client):
    try:
        buckets = client.list_buckets()
        print("Buckets:", buckets)
        logging.info(f"Buckets: {buckets}")
    except Exception as e:
        logging.error(f"Error listing buckets: {e}")

def main():
    # parser = argparse.ArgumentParser(description='Run the script locally or in the cloud.')
    # parser.add_argument('--local', action='store_true', help='Run the script locally with credentials path')
    # args = parser.parse_args()

    project_id = os.getenv('GCP_PROJECT_ID', 'smart-axis-421517')
    bucket_name = os.getenv('BUCKET_NAME', 'loc-scraper')

    credentials_path = None
    # if args.local:
    credentials_path = os.getenv('GCP_CREDENTIALS_PATH', 'secret.json')

    # Initialize logging
    logging_client = initialize_google_cloud_logging_client(project_id,credentials_path)
    logging_client.setup_logging()

    # List Buckets for testing
    gcs_client = initialize_gcs_client(project_id, credentials_path)
    list_gcs_buckets(gcs_client)

    # Grab A blob from the heap
    first_blob = gcs_client.pop_blob(bucket_name)
    if first_blob:
        print(f"First blob name: {first_blob.name}")


if __name__ == "__main__":
    main()
```

    trying creds file
    Buckets: ['loc-scraper', 'loc_flattener_processed', 'processed_results', 'smart-axis-421517_cloudbuild']
    First valid blob selected: last_page.txt
    First blob name: last_page.txt


#### Some additions to avoid last_page.txt

So there is a last page.txt that is used by the scraper program. I want to pass some regex patterns to exclude in the pop_blob method


```python
def pop_blob(self, bucket_name, patterns_file = None):
        """
        Selects and removes the first blob from the specified bucket in Google Cloud Storage,
        excluding any blobs that match patterns from the provided file.

        Args:
            bucket_name (str): Name of the bucket.
            patterns_file (str, optional): Path to the file containing regex patterns to exclude.

        Returns:
            google.cloud.storage.blob.Blob: The first blob from the bucket that doesn't match any pattern.
        """
        # Load regex patterns from file
        patterns = []
        if patterns_file:
            with open(patterns_file, 'r') as file:
                patterns = [line.strip() for line in file]

        # Get the bucket
        bucket = self.client.bucket(bucket_name)
        
        # List all blobs in the bucket
        blobs = list(bucket.list_blobs())
        
        if not blobs:
            print(f"No blobs found in bucket '{bucket_name}'.")
            return None

        # Filter blobs based on regex patterns
        for blob in blobs:
            if not any(re.search(pattern, blob.name) for pattern in patterns):
                print(f"First valid blob selected: {blob.name}")
                return blob

        print("No valid blobs found after applying regex patterns.")
        return None
```


```python
def initialize_google_cloud_logging_client(project_id, credentials_path=None):
    return GoogleCloudLogging(project_id, credentials_path=credentials_path)

def initialize_gcs_client(project_id, credentials_path=None):
    return GCSClient(project_id, credentials_path=credentials_path)

def list_gcs_buckets(client):
    try:
        buckets = client.list_buckets()
        print("Buckets:", buckets)
        logging.info(f"Buckets: {buckets}")
    except Exception as e:
        logging.error(f"Error listing buckets: {e}")

def main():
    # parser = argparse.ArgumentParser(description='Run the script locally or in the cloud.')
    # parser.add_argument('--local', action='store_true', help='Run the script locally with credentials path')
    # args = parser.parse_args()

    patterns_file = os.getenv('PATTERNS_FILE', 'exclude.txt')
    project_id = os.getenv('GCP_PROJECT_ID', 'smart-axis-421517')
    bucket_name = os.getenv('BUCKET_NAME', 'loc-scraper')

    credentials_path = None
    # if args.local:
    credentials_path = os.getenv('GCP_CREDENTIALS_PATH', 'secret.json')

    # Initialize logging
    logging_client = initialize_google_cloud_logging_client(project_id,credentials_path)
    logging_client.setup_logging()

    # List Buckets for testing
    gcs_client = initialize_gcs_client(project_id, credentials_path)
    list_gcs_buckets(gcs_client)

    # Grab A blob from the heap
    first_blob = gcs_client.pop_blob(bucket_name,patterns_file )
    if first_blob:
        print(f"First blob name: {first_blob.name}")


if __name__ == "__main__":
    main()
```

    trying creds file
    Buckets: ['loc-scraper', 'loc_flattener_processed', 'processed_results', 'smart-axis-421517_cloudbuild']
    First valid blob selected: result-10.json
    First blob name: result-10.json


### Download the data

Now I need to process the information. First off i need to grab the data from the blob



```python
def download_blob_to_memory(self, bucket_name, blob_name):
        """
        Downloads a blob from the specified bucket to memory.

        Args:
            bucket_name (str): Name of the bucket.
            blob_name (str): Name of the blob to download.

        Returns:
            string: The string content of the blob.
        """
        # Get the bucket
        bucket = self.client.bucket(bucket_name)
        
        # Get the blob
        blob = bucket.blob(blob_name)

        # Download the blob to a string
        blob_data = blob.download_as_string()
        
        # Parse the JSON content
        # json_content = json.loads(blob_data)
        
        print(f"Blob '{blob_name}' downloaded to memory.")
        return blob_data
```


```python
def initialize_google_cloud_logging_client(project_id, credentials_path=None):
    return GoogleCloudLogging(project_id, credentials_path=credentials_path)

def initialize_gcs_client(project_id, credentials_path=None):
    return GCSClient(project_id, credentials_path=credentials_path)

def list_gcs_buckets(client):
    try:
        buckets = client.list_buckets()
        print("Buckets:", buckets)
        logging.info(f"Buckets: {buckets}")
    except Exception as e:
        logging.error(f"Error listing buckets: {e}")

def main():
    # parser = argparse.ArgumentParser(description='Run the script locally or in the cloud.')
    # parser.add_argument('--local', action='store_true', help='Run the script locally with credentials path')
    # args = parser.parse_args()

    patterns_file = os.getenv('PATTERNS_FILE', 'exclude.txt')
    project_id = os.getenv('GCP_PROJECT_ID', 'smart-axis-421517')
    bucket_name = os.getenv('BUCKET_NAME', 'loc-scraper')

    credentials_path = None
    # if args.local:
    credentials_path = os.getenv('GCP_CREDENTIALS_PATH', 'secret.json')

    # Initialize logging
    logging_client = initialize_google_cloud_logging_client(project_id,credentials_path)
    logging_client.setup_logging()

    # List Buckets for testing
    gcs_client = initialize_gcs_client(project_id, credentials_path)
    list_gcs_buckets(gcs_client)

    # Grab A blob from the heap
    first_blob = gcs_client.pop_blob(bucket_name,patterns_file )
    if first_blob:
        print(f"First blob name: {first_blob.name}")


#download to memory

    blob_data = gcs_client.download_blob_to_memory(bucket_name, first_blob.name)
    json_data = json.loads(blob_data)
    
    print(blob_data[0:100])
    # create_gcs_bucket(gcs_client, bucket_name)

if __name__ == "__main__":
    main()
```

    trying creds file
    Buckets: ['loc-scraper', 'loc_flattener_processed', 'processed_results', 'smart-axis-421517_cloudbuild']
    First valid blob selected: result-10.json
    First blob name: result-10.json
    Blob 'result-10.json' downloaded to memory.
    b'{"breadcrumbs": [{"Library of Congress": "https://www.loc.gov"}, {"Digital Collections": "https://ww'


#### Flatten and process the JSON

There is a ton of information in the json. I need to explore it. 




```python
def initialize_google_cloud_logging_client(project_id, credentials_path=None):
    return GoogleCloudLogging(project_id, credentials_path=credentials_path)

def initialize_gcs_client(project_id, credentials_path=None):
    return GCSClient(project_id, credentials_path=credentials_path)

def list_gcs_buckets(client):
    try:
        buckets = client.list_buckets()
        print("Buckets:", buckets)
        logging.info(f"Buckets: {buckets}")
    except Exception as e:
        logging.error(f"Error listing buckets: {e}")


    # parser = argparse.ArgumentParser(description='Run the script locally or in the cloud.')
    # parser.add_argument('--local', action='store_true', help='Run the script locally with credentials path')
    # args = parser.parse_args()
patterns_file = os.getenv('PATTERNS_FILE', 'exclude.txt')
project_id = os.getenv('GCP_PROJECT_ID', 'smart-axis-421517')
bucket_name = os.getenv('BUCKET_NAME', 'loc-scraper')

credentials_path = None
# if args.local:
credentials_path = os.getenv('GCP_CREDENTIALS_PATH', 'secret.json')

# Initialize logging
logging_client = initialize_google_cloud_logging_client(project_id,credentials_path)
logging_client.setup_logging()

# List Buckets for testing
gcs_client = initialize_gcs_client(project_id, credentials_path)
list_gcs_buckets(gcs_client)

# Grab A blob from the heap
first_blob = gcs_client.pop_blob(bucket_name,patterns_file )
if first_blob:
    print(f"First blob name: {first_blob.name}")


#download to memory

blob_data = gcs_client.download_blob_to_memory(bucket_name, first_blob.name)
json_data = json.loads(blob_data)
    
print(blob_data[0:100])
    # create_gcs_bucket(gcs_client, bucket_name)
```

    trying creds file
    Buckets: ['loc-scraper', 'loc_flattener_processed', 'processed_results', 'smart-axis-421517_cloudbuild']
    First valid blob selected: result-10.json
    First blob name: result-10.json
    Blob 'result-10.json' downloaded to memory.
    b'{"breadcrumbs": [{"Library of Congress": "https://www.loc.gov"}, {"Digital Collections": "https://ww'



```python
json_data.keys()
```




    dict_keys(['breadcrumbs', 'browse', 'categories', 'content', 'content_is_post', 'expert_resources', 'facet_trail', 'facet_views', 'facets', 'form_facets', 'next', 'next_sibling', 'options', 'original_formats', 'pages', 'pagination', 'partof', 'previous', 'previous_sibling', 'research-centers', 'results', 'search', 'shards', 'site_type', 'subjects', 'timestamp', 'title', 'topics', 'views'])




```python
json_data["results"][0]
```




    {'access_restricted': False,
     'aka': ['http://www.loc.gov/item/usrep308213/',
      'http://www.loc.gov/resource/usrep.usrep308213/',
      'http://www.loc.gov/item/usrep.usrep308213/'],
     'campaigns': [],
     'contributor': ['stone, harlan fiske', 'supreme court of the united states'],
     'date': '1939',
     'dates': ['1939'],
     'digitized': True,
     'extract_timestamp': '2023-12-04T18:41:50.547Z',
     'group': ['usrep103', 'us-report'],
     'hassegments': False,
     'id': 'http://www.loc.gov/item/usrep308213/',
     'image_url': ['https://tile.loc.gov/storage-services/service/ll/usrep/usrep308/usrep308213/usrep308213.gif#h=150&w=100'],
     'index': 631,
     'item': {'call_number': ['Call Number: KF101',
       'Series: Administrative Law',
       'Series: Volume 308'],
      'contributors': ['Stone, Harlan Fiske (Judge)',
       'Supreme Court of the United States (Author)'],
      'created_published': ['1939'],
      'date': '19390000',
      'format': 'periodical',
      'genre': ['Periodical'],
      'language': ['eng'],
      'notes': ['Description: U.S. Reports Volume 308; October Term, 1939; Union Stock Yard & Transit Co. v. United States et al.'],
      'rights': 'no known restrictions on use or reproduction',
      'source_collection': 'U.S. Reports',
      'subjects': ['Livestock',
       'Law',
       'Railroads',
       'Law Library',
       'Supreme Court',
       'United States',
       'Government Documents',
       'Judicial review and appeals',
       'Agency',
       'Tariffs',
       'Interstate commerce',
       'Administrative law and regulatory procedure',
       'U.S. Reports',
       'Common law',
       'Court opinions',
       'Judicial decisions',
       'Court cases',
       'Court decisions',
       'Interstate Commerce Commission (I.C.C.)',
       'Agency jurisdiction',
       'Periodical'],
      'title': 'U.S. Reports: Union Stock Yard Co. v. U.S., 308 U.S. 213 (1939).'},
     'language': ['english'],
     'mime_type': ['image/gif', 'application/pdf'],
     'online_format': ['image', 'pdf'],
     'original_format': ['periodical'],
     'other_title': [],
     'partof': ['u.s. reports: volume 308',
      'u.s. reports: administrative law',
      'law library of congress',
      'united states reports (official opinions of the u.s. supreme court)'],
     'resources': [{'files': 1,
       'image': 'https://tile.loc.gov/storage-services/service/ll/usrep/usrep308/usrep308213/usrep308213.gif',
       'pdf': 'https://tile.loc.gov/storage-services/service/ll/usrep/usrep308/usrep308213/usrep308213.pdf',
       'url': 'https://www.loc.gov/resource/usrep.usrep308213/'}],
     'shelf_id': 'Call Number: KF101 Series: Administrative Law Series: Volume 308',
     'subject': ['administrative law',
      'livestock',
      'railroads',
      'supreme court',
      'united states',
      'court opinions',
      'periodical',
      'agency',
      'interstate commerce',
      'court cases',
      'judicial decisions',
      'law library',
      'interstate commerce commission (i.c.c.)',
      'judicial review and appeals',
      'government documents',
      'administrative law and regulatory procedure',
      'law',
      'common law',
      'court decisions',
      'u.s. reports',
      'tariffs',
      'agency jurisdiction'],
     'subject_major_case_topic': ['administrative law'],
     'timestamp': '2023-12-04T19:05:12.397Z',
     'title': 'U.S. Reports: Union Stock Yard Co. v. U.S., 308 U.S. 213 (1939).',
     'type': ['periodical'],
     'url': 'https://www.loc.gov/item/usrep308213/'}



#### Use Pandas to normalize the data


```python
       # Flatten the JSON content
df_main = pd.json_normalize(json_data["results"][0])
        
        # Normalize nested structures
```


```python
item_data = json_data["results"][0]['item']
resources_data = json_data["results"][0]['resources']
        
df_item = pd.json_normalize(item_data)
df_item['id'] = json_data["results"][0]['id']  # Add 'id' for joining



```


```python
df_resources = pd.json_normalize(resources_data)
df_resources['id'] = json_data["results"][0]['id']  # Add 'id' for joining
        
```


```python
df_item
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>call_number</th>
      <th>contributors</th>
      <th>created_published</th>
      <th>date</th>
      <th>format</th>
      <th>genre</th>
      <th>language</th>
      <th>notes</th>
      <th>rights</th>
      <th>source_collection</th>
      <th>subjects</th>
      <th>title</th>
      <th>id</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>[Call Number: KF101, Series: Administrative La...</td>
      <td>[Stone, Harlan Fiske (Judge), Supreme Court of...</td>
      <td>[1939]</td>
      <td>19390000</td>
      <td>periodical</td>
      <td>[Periodical]</td>
      <td>[eng]</td>
      <td>[Description: U.S. Reports Volume 308; October...</td>
      <td>no known restrictions on use or reproduction</td>
      <td>U.S. Reports</td>
      <td>[Livestock, Law, Railroads, Law Library, Supre...</td>
      <td>U.S. Reports: Union Stock Yard Co. v. U.S., 30...</td>
      <td>http://www.loc.gov/item/usrep308213/</td>
    </tr>
  </tbody>
</table>
</div>




```python
df_resources
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>files</th>
      <th>image</th>
      <th>pdf</th>
      <th>url</th>
      <th>id</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>1</td>
      <td>https://tile.loc.gov/storage-services/service/...</td>
      <td>https://tile.loc.gov/storage-services/service/...</td>
      <td>https://www.loc.gov/resource/usrep.usrep308213/</td>
      <td>http://www.loc.gov/item/usrep308213/</td>
    </tr>
  </tbody>
</table>
</div>




```python
df_main
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>access_restricted</th>
      <th>aka</th>
      <th>campaigns</th>
      <th>contributor</th>
      <th>date</th>
      <th>dates</th>
      <th>digitized</th>
      <th>extract_timestamp</th>
      <th>group</th>
      <th>hassegments</th>
      <th>...</th>
      <th>item.created_published</th>
      <th>item.date</th>
      <th>item.format</th>
      <th>item.genre</th>
      <th>item.language</th>
      <th>item.notes</th>
      <th>item.rights</th>
      <th>item.source_collection</th>
      <th>item.subjects</th>
      <th>item.title</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>False</td>
      <td>[http://www.loc.gov/item/usrep308213/, http://...</td>
      <td>[]</td>
      <td>[stone, harlan fiske, supreme court of the uni...</td>
      <td>1939</td>
      <td>[1939]</td>
      <td>True</td>
      <td>2023-12-04T18:41:50.547Z</td>
      <td>[usrep103, us-report]</td>
      <td>False</td>
      <td>...</td>
      <td>[1939]</td>
      <td>19390000</td>
      <td>periodical</td>
      <td>[Periodical]</td>
      <td>[eng]</td>
      <td>[Description: U.S. Reports Volume 308; October...</td>
      <td>no known restrictions on use or reproduction</td>
      <td>U.S. Reports</td>
      <td>[Livestock, Law, Railroads, Law Library, Supre...</td>
      <td>U.S. Reports: Union Stock Yard Co. v. U.S., 30...</td>
    </tr>
  </tbody>
</table>
<p>1 rows × 39 columns</p>
</div>




```python
# df_call_number = pd.DataFrame(df_item["call_number"], columns=['call_number'])
# df_call_number['id'] = json_data["results"][0]['id']  # Add 'id' for joining

call_numbers = item_data.get('call_number', [])
df_call_number = pd.DataFrame(call_numbers, columns=['call_number'])
df_call_number['id'] = json_data["results"][0]['id']  # Add 'id' for joining
        
```


```python
df_call_number
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>call_number</th>
      <th>id</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>Call Number: KF101</td>
      <td>http://www.loc.gov/item/usrep308213/</td>
    </tr>
    <tr>
      <th>1</th>
      <td>Series: Administrative Law</td>
      <td>http://www.loc.gov/item/usrep308213/</td>
    </tr>
    <tr>
      <th>2</th>
      <td>Series: Volume 308</td>
      <td>http://www.loc.gov/item/usrep308213/</td>
    </tr>
  </tbody>
</table>
</div>




```python
subjects = item_data.get('subjects', [])
df_subjects = pd.DataFrame(subjects, columns=['subjects'])
df_subjects['id'] = json_data["results"][0]['id']  # Add 'id' for joining
        
```


```python
df_subjects
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>subjects</th>
      <th>id</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>Livestock</td>
      <td>http://www.loc.gov/item/usrep308213/</td>
    </tr>
    <tr>
      <th>1</th>
      <td>Law</td>
      <td>http://www.loc.gov/item/usrep308213/</td>
    </tr>
    <tr>
      <th>2</th>
      <td>Railroads</td>
      <td>http://www.loc.gov/item/usrep308213/</td>
    </tr>
    <tr>
      <th>3</th>
      <td>Law Library</td>
      <td>http://www.loc.gov/item/usrep308213/</td>
    </tr>
    <tr>
      <th>4</th>
      <td>Supreme Court</td>
      <td>http://www.loc.gov/item/usrep308213/</td>
    </tr>
    <tr>
      <th>5</th>
      <td>United States</td>
      <td>http://www.loc.gov/item/usrep308213/</td>
    </tr>
    <tr>
      <th>6</th>
      <td>Government Documents</td>
      <td>http://www.loc.gov/item/usrep308213/</td>
    </tr>
    <tr>
      <th>7</th>
      <td>Judicial review and appeals</td>
      <td>http://www.loc.gov/item/usrep308213/</td>
    </tr>
    <tr>
      <th>8</th>
      <td>Agency</td>
      <td>http://www.loc.gov/item/usrep308213/</td>
    </tr>
    <tr>
      <th>9</th>
      <td>Tariffs</td>
      <td>http://www.loc.gov/item/usrep308213/</td>
    </tr>
    <tr>
      <th>10</th>
      <td>Interstate commerce</td>
      <td>http://www.loc.gov/item/usrep308213/</td>
    </tr>
    <tr>
      <th>11</th>
      <td>Administrative law and regulatory procedure</td>
      <td>http://www.loc.gov/item/usrep308213/</td>
    </tr>
    <tr>
      <th>12</th>
      <td>U.S. Reports</td>
      <td>http://www.loc.gov/item/usrep308213/</td>
    </tr>
    <tr>
      <th>13</th>
      <td>Common law</td>
      <td>http://www.loc.gov/item/usrep308213/</td>
    </tr>
    <tr>
      <th>14</th>
      <td>Court opinions</td>
      <td>http://www.loc.gov/item/usrep308213/</td>
    </tr>
    <tr>
      <th>15</th>
      <td>Judicial decisions</td>
      <td>http://www.loc.gov/item/usrep308213/</td>
    </tr>
    <tr>
      <th>16</th>
      <td>Court cases</td>
      <td>http://www.loc.gov/item/usrep308213/</td>
    </tr>
    <tr>
      <th>17</th>
      <td>Court decisions</td>
      <td>http://www.loc.gov/item/usrep308213/</td>
    </tr>
    <tr>
      <th>18</th>
      <td>Interstate Commerce Commission (I.C.C.)</td>
      <td>http://www.loc.gov/item/usrep308213/</td>
    </tr>
    <tr>
      <th>19</th>
      <td>Agency jurisdiction</td>
      <td>http://www.loc.gov/item/usrep308213/</td>
    </tr>
    <tr>
      <th>20</th>
      <td>Periodical</td>
      <td>http://www.loc.gov/item/usrep308213/</td>
    </tr>
  </tbody>
</table>
</div>




```python
notes = item_data.get('notes', [])
df_notes = pd.DataFrame(notes, columns=['notes'])
df_notes['id'] = json_data["results"][0]['id']  # Add 'id' for joining
df_notes
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>notes</th>
      <th>id</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>Description: U.S. Reports Volume 308; October ...</td>
      <td>http://www.loc.gov/item/usrep308213/</td>
    </tr>
  </tbody>
</table>
</div>



##### Putting it together


```python
def normalize_main(result):
    df_main = pd.json_normalize(result)
    return df_main

def normalize_item(result):
    item_data = result['item']
    df_item = pd.json_normalize(item_data)
    df_item['id'] = result['id']  # Add 'id' for joining
    return df_item

def normalize_resources(result):
    resources_data = result['resources']
    df_resources = pd.json_normalize(resources_data)
    df_resources['id'] = result['id']  # Add 'id' for joining
    return df_resources

def normalize_call_numbers(result):
    item_data = result['item']
    call_numbers = item_data.get('call_number', [])
    df_call_number = pd.DataFrame(call_numbers, columns=['call_number'])
    df_call_number['id'] = result['id']  # Add 'id' for joining
    return df_call_number

def normalize_contributors(result):
    item_data = result['item']
    contributors = item_data.get('contributors', [])
    df_contributors = pd.DataFrame(contributors, columns=['contributors'])
    df_contributors['id'] = result['id']  # Add 'id' for joining
    return df_contributors

def normalize_subjects(result):
    item_data = result['item']
    subjects = item_data.get('subjects', [])
    df_subjects = pd.DataFrame(subjects, columns=['subjects'])
    df_subjects['id'] = result['id']  # Add 'id' for joining
    return df_subjects

def normalize_notes(result):
    item_data = result['item']
    notes = item_data.get('notes', [])
    df_notes = pd.DataFrame(notes, columns=['notes'])
    df_notes['id'] = result['id']  # Add 'id' for joining
    return df_notes
```


```python
def initialize_google_cloud_logging_client(project_id, credentials_path=None):
    return GoogleCloudLogging(project_id, credentials_path=credentials_path)

def initialize_gcs_client(project_id, credentials_path=None):
    return GCSClient(project_id, credentials_path=credentials_path)

def initialize_bq_client(project_id,credentials_path=None):
    return BigQueryClient(project_id,credentials_path = credentials_path)

def list_gcs_buckets(client):
    try:
        buckets = client.list_buckets()
        print("Buckets:", buckets)
        logging.info(f"Buckets: {buckets}")
    except Exception as e:
        logging.error(f"Error listing buckets: {e}")

def main():
    # parser = argparse.ArgumentParser(description='Run the script locally or in the cloud.')
    # parser.add_argument('--local', action='store_true', help='Run the script locally with credentials path')
    # args = parser.parse_args()

    patterns_file = os.getenv('PATTERNS_FILE', 'exclude.txt')
    project_id = os.getenv('GCP_PROJECT_ID', 'smart-axis-421517')
    bucket_name = os.getenv('BUCKET_NAME', 'loc-scraper')

    credentials_path = None
    # if args.local:
    credentials_path = os.getenv('GCP_CREDENTIALS_PATH', 'secret.json')

    # Initialize logging
    logging_client = initialize_google_cloud_logging_client(project_id,credentials_path)
    logging_client.setup_logging()

    # List Buckets for testing
    gcs_client = initialize_gcs_client(project_id, credentials_path)
    list_gcs_buckets(gcs_client)

    # initialize bq

    bq_client = initialize_bq_client(project_id,credentials_path)

    # Grab A blob from the heap
    first_blob = gcs_client.pop_blob(bucket_name,patterns_file )
    if first_blob:
        print(f"First blob name: {first_blob.name}")


#download to memory

    blob_data = gcs_client.download_blob_to_memory(bucket_name, first_blob.name)
    json_data = json.loads(blob_data)
    
    print(blob_data[0:100])
    # create_gcs_bucket(gcs_client, bucket_name)

    results = json_data["results"]

    # Initialize lists to hold DataFramesdf_notes
    df_main_list = []
    df_item_list = []
    df_resources_list = []
    df_call_number_list = []
    df_contributors_list = []
    df_subjects_list = []
    df_notes_list = []

    for result in results:
        df_main_list.append(normalize_main(result))
        df_item_list.append(normalize_item(result))
        df_resources_list.append(normalize_resources(result))
        df_call_number_list.append(normalize_call_numbers(result))
        df_contributors_list.append(normalize_contributors(result))
        df_subjects_list.append(normalize_subjects(result))
        df_notes_list.append(normalize_notes(result))

    # Concatenate all DataFrames
    df_main = pd.concat(df_main_list, ignore_index=True)
    df_item = pd.concat(df_item_list, ignore_index=True)
    df_resources = pd.concat(df_resources_list, ignore_index=True)
    df_call_number = pd.concat(df_call_number_list, ignore_index=True)
    df_contributors = pd.concat(df_contributors_list, ignore_index=True)
    df_subjects = pd.concat(df_subjects_list, ignore_index=True)
    df_notes = pd.concat(df_notes_list, ignore_index=True)

if __name__ == "__main__":
    main()
```

    trying creds file
    Buckets: ['loc-scraper', 'loc_flattener_processed', 'processed_results', 'smart-axis-421517_cloudbuild']
    First valid blob selected: result-10.json
    First blob name: result-10.json
    Blob 'result-10.json' downloaded to memory.
    b'{"breadcrumbs": [{"Library of Congress": "https://www.loc.gov"}, {"Digital Collections": "https://ww'



```python
# parser = argparse.ArgumentParser(description='Run the script locally or in the cloud.')
# parser.add_argument('--local', action='store_true', help='Run the script locally with credentials path')
# args = parser.parse_args()

def initialize_google_cloud_logging_client(project_id, credentials_path=None):
    return GoogleCloudLogging(project_id, credentials_path=credentials_path)

def initialize_gcs_client(project_id, credentials_path=None):
    return GCSClient(project_id, credentials_path=credentials_path)

def initialize_bq_client(project_id,credentials_path=None):
    return BigQueryClient(project_id,credentials_path = credentials_path)

def list_gcs_buckets(client):
    try:
        buckets = client.list_buckets()
        print("Buckets:", buckets)
        logging.info(f"Buckets: {buckets}")
    except Exception as e:
        logging.error(f"Error listing buckets: {e}")

def main():
    # parser = argparse.ArgumentParser(description='Run the script locally or in the cloud.')
    # parser.add_argument('--local', action='store_true', help='Run the script locally with credentials path')
    # args = parser.parse_args()

    main_table_id = "results_staging"
    item_table_id = "items_staging"
    resources_table_id = "resources_staging"
    call_number_table_id = "call_numbers_staging"
    contributors_table_id = "contributors_staging"
    subjects_table_id = "subjects_staging"
    notes_table_id = "notes_staging"
    
    dataset_id = "supreme_court"
    
    patterns_file = os.getenv('PATTERNS_FILE', 'exclude.txt')
    project_id = os.getenv('GCP_PROJECT_ID', 'smart-axis-421517')
    bucket_name = os.getenv('BUCKET_NAME', 'loc-scraper')
    
    credentials_path = None
    # if args.local:
    credentials_path = os.getenv('GCP_CREDENTIALS_PATH', 'secret.json')
    
    # Initialize logging
    logging_client = initialize_google_cloud_logging_client(project_id,credentials_path)
    logging_client.setup_logging()
    
    # List Buckets for testing
    gcs_client = initialize_gcs_client(project_id, credentials_path)
    list_gcs_buckets(gcs_client)
    
    bq_client = initialize_bq_client(project_id,credentials_path)
    
    # Create the dataset if not exists
    
    bq_client.create_dataset(dataset_id)
    
    # Grab A blob from the heap
    first_blob = gcs_client.pop_blob(bucket_name,patterns_file )
    if first_blob:
        print(f"First blob name: {first_blob.name}")
    
    
    #download to memory
    
    blob_data = gcs_client.download_blob_to_memory(bucket_name, first_blob.name)
    json_data = json.loads(blob_data)
    
    # print(blob_data[0:100])
    # create_gcs_bucket(gcs_client, bucket_name)
    
    results = json_data["results"]
    
    # Initialize lists to hold DataFrames
    df_main_list = []
    df_item_list = []
    df_resources_list = []
    df_call_number_list = []
    df_contributors_list = []
    df_subjects_list = []
    df_notes_list = []
    
    for result in results:
        df_main_list.append(normalize_main(result))
        df_item_list.append(normalize_item(result))
        df_resources_list.append(normalize_resources(result))
        df_call_number_list.append(normalize_call_numbers(result))
        df_contributors_list.append(normalize_contributors(result))
        df_subjects_list.append(normalize_subjects(result))
        df_notes_list.append(normalize_notes(result))
    
    # Concatenate all DataFrames
    df_main = pd.concat(df_main_list, ignore_index=True)
    df_item = pd.concat(df_item_list, ignore_index=True)
    df_resources = pd.concat(df_resources_list, ignore_index=True)
    df_call_number = pd.concat(df_call_number_list, ignore_index=True)
    df_contributors = pd.concat(df_contributors_list, ignore_index=True)
    df_subjects = pd.concat(df_subjects_list, ignore_index=True)
    df_notes = pd.concat(df_notes_list, ignore_index=True)
    
    # Define the BigQuery table schema
    # main_schema = [bigquery.SchemaField(name, bigquery.enums.SqlTypeNames.STRING) for name in df_main.columns]
    item_schema = [bigquery.SchemaField(name, bigquery.enums.SqlTypeNames.STRING) for name in df_item.columns]
    resources_schema = [bigquery.SchemaField(name, bigquery.enums.SqlTypeNames.STRING) for name in df_resources.columns]
    call_number_schema = [bigquery.SchemaField(name, bigquery.enums.SqlTypeNames.STRING) for name in df_call_number.columns]
    contributors_schema = [bigquery.SchemaField(name, bigquery.enums.SqlTypeNames.STRING) for name in df_contributors.columns]
    subjects_schema = [bigquery.SchemaField(name, bigquery.enums.SqlTypeNames.STRING) for name in df_subjects.columns]
    notes_schema = [bigquery.SchemaField(name, bigquery.enums.SqlTypeNames.STRING) for name in df_notes.columns]
    
    # Create BigQuery tables
    # bq_client.create_table(dataset_id, main_table_id, main_schema)
    bq_client.create_table(dataset_id, item_table_id, item_schema)
    bq_client.create_table(dataset_id, resources_table_id, resources_schema)
    bq_client.create_table(dataset_id, call_number_table_id, call_number_schema)
    bq_client.create_table(dataset_id, contributors_table_id, contributors_schema)
    bq_client.create_table(dataset_id, subjects_table_id, subjects_schema)
    bq_client.create_table(dataset_id, notes_table_id, notes_schema)
    
    # Load DataFrames into BigQuery tables
    # bq_client.load_dataframe_to_table(dataset_id, main_table_id, df_main)
    bq_client.load_dataframe_to_table(dataset_id, item_table_id, df_item)
    bq_client.load_dataframe_to_table(dataset_id, resources_table_id, df_resources)
    bq_client.load_dataframe_to_table(dataset_id, call_number_table_id, df_call_number)
    bq_client.load_dataframe_to_table(dataset_id, contributors_table_id, df_contributors)
    bq_client.load_dataframe_to_table(dataset_id, subjects_table_id, df_subjects)
    bq_client.load_dataframe_to_table(dataset_id, notes_table_id, df_notes)

if __name__ == "__main__":
    main()
```

    trying creds file
    Buckets: ['loc-scraper', 'loc_flattener_processed', 'processed_results', 'smart-axis-421517_cloudbuild']
    Dataset supreme_court created.
    First valid blob selected: result-10.json
    First blob name: result-10.json
    Blob 'result-10.json' downloaded to memory.
    Table items_staging created in dataset supreme_court.
    Table resources_staging created in dataset supreme_court.
    Table call_numbers_staging created in dataset supreme_court.
    Table contributors_staging created in dataset supreme_court.
    Table subjects_staging created in dataset supreme_court.
    Table notes_staging created in dataset supreme_court.
    Loaded 70 rows into supreme_court:items_staging.
    Loaded 70 rows into supreme_court:resources_staging.
    Loaded 210 rows into supreme_court:call_numbers_staging.
    Loaded 138 rows into supreme_court:contributors_staging.
    Loaded 1570 rows into supreme_court:subjects_staging.
    Loaded 70 rows into supreme_court:notes_staging.


#### Moving the Processed blobs to a Processed Bucket

##### Add code to the GCS Client to enable deleting and copying


```python
def copy_blob(self, source_bucket_name, source_blob_name, destination_bucket_name, destination_blob_name):
        """
        Copies a blob from one bucket to another.

        Args:
            source_bucket_name (str): Name of the source bucket.
            source_blob_name (str): Name of the source blob.
            destination_bucket_name (str): Name of the destination bucket.
            destination_blob_name (str): Name of the destination blob.

        Returns:
            google.cloud.storage.blob.Blob: The copied blob.
        """
        source_bucket = self.client.bucket(source_bucket_name)
        source_blob = source_bucket.blob(source_blob_name)
        destination_bucket = self.client.bucket(destination_bucket_name)
        blob_copy = source_bucket.copy_blob(source_blob, destination_bucket, destination_blob_name)
        return blob_copy

def delete_blob(self, bucket_name, blob_name):
        """
        Deletes a blob from the specified bucket.

        Args:
            bucket_name (str): Name of the bucket.
            blob_name (str): Name of the blob to delete.
        """
        bucket = self.client.bucket(bucket_name)
        blob = bucket.blob(blob_name)
        blob.delete()
```

##### Add a couple lines to the main script to call the new methods


```Python
# Move the blob to the processed_results bucket
gcs_client.copy_blob(bucket_name, first_blob.name, processed_bucket_name, first_blob.name)
gcs_client.delete_blob(bucket_name, first_blob.name)
print(f"Blob {first_blob.name} moved to {processed_bucket_name} and deleted from {bucket_name}")
```


```python
#### Testing
# loc_flattener.py
# library_of_congress_scraper.py

# loc_flattener.py
# library_of_congress_scraper.py

from __future__ import print_function
from gcputils.gcpclient import GCSClient
from gcputils.GoogleCloudLogging import GoogleCloudLogging
from gcputils.BigQueryClient import BigQueryClient
from bs4 import BeautifulSoup
import requests
import json
import os
import time
from pprint import pprint
import html
from flatten_json import flatten
import google.cloud.logging
import logging
import argparse
import pandas as pd
from google.cloud import bigquery

def initialize_gcs_client(project_id, credentials_path=None):
    return GCSClient(project_id, credentials_path=credentials_path)
    

def initialize_google_cloud_logging_client(project_id, credentials_path=None):
    return GoogleCloudLogging(project_id, credentials_path=credentials_path)

def initialize_bq_client(project_id,credentials_path=None):
    return BigQueryClient(project_id,credentials_path = credentials_path)

def list_gcs_buckets(client):
    try:
        buckets = client.list_buckets()
        print("Buckets:", buckets)
        logging.info(f"Buckets: {buckets}")
    except Exception as e:
        logging.error(f"Error listing buckets: {e}")

def create_gcs_bucket(client, bucket_name):
    try:
        bucket = client.create_bucket(bucket_name=bucket_name)
        logging.info(bucket)
        print(bucket)
    except Exception as e:
        logging.error(f"Error creating bucket: {e}")

def normalize_main(result):
    df_main = pd.json_normalize(result)
    return df_main

def normalize_item(result):
    item_data = result['item']
    df_item = pd.json_normalize(item_data)
    df_item['id'] = result['id']  # Add 'id' for joining
    return df_item

def normalize_resources(result):
    resources_data = result['resources']
    df_resources = pd.json_normalize(resources_data)
    df_resources['id'] = result['id']  # Add 'id' for joining
    return df_resources

def normalize_call_numbers(result):
    item_data = result['item']
    call_numbers = item_data.get('call_number', [])
    df_call_number = pd.DataFrame(call_numbers, columns=['call_number'])
    df_call_number['id'] = result['id']  # Add 'id' for joining
    return df_call_number

def normalize_contributors(result):
    item_data = result['item']
    contributors = item_data.get('contributors', [])
    df_contributors = pd.DataFrame(contributors, columns=['contributors'])
    df_contributors['id'] = result['id']  # Add 'id' for joining
    return df_contributors

def normalize_subjects(result):
    item_data = result['item']
    subjects = item_data.get('subjects', [])
    df_subjects = pd.DataFrame(subjects, columns=['subjects'])
    df_subjects['id'] = result['id']  # Add 'id' for joining
    return df_subjects

def normalize_notes(result):
    item_data = result['item']
    notes = item_data.get('notes', [])
    df_notes = pd.DataFrame(notes, columns=['notes'])
    df_notes['id'] = result['id']  # Add 'id' for joining
    return df_notes

def main():
    # parser = argparse.ArgumentParser(description='Run the script locally or in the cloud.')
    # parser.add_argument('--local', action='store_true', help='Run the script locally with credentials path')
    # args = parser.parse_args()

    main_table_id = "results_staging"
    item_table_id = "items_staging"
    resources_table_id = "resources_staging"
    call_number_table_id = "call_numbers_staging"
    contributors_table_id = "contributors_staging"
    subjects_table_id = "subjects_staging"
    notes_table_id = "notes_staging"

    processed_bucket_name = "loc_flattener_processed"
    
    dataset_id = "supreme_court"
    
    patterns_file = os.getenv('PATTERNS_FILE', 'exclude.txt')
    project_id = os.getenv('GCP_PROJECT_ID', 'smart-axis-421517')
    bucket_name = os.getenv('BUCKET_NAME', 'loc-scraper')
    
    credentials_path = None
    # if args.local:
    credentials_path = os.getenv('GCP_CREDENTIALS_PATH', 'secret.json')
    
    # Initialize logging
    logging_client = initialize_google_cloud_logging_client(project_id,credentials_path)
    logging_client.setup_logging()
    
    # List Buckets for testing
    gcs_client = initialize_gcs_client(project_id, credentials_path)
    list_gcs_buckets(gcs_client)
    
    bq_client = initialize_bq_client(project_id,credentials_path)
    
    # Create the dataset if not exists
    
    bq_client.create_dataset(dataset_id)

    # create the processed_bucket if not exists

    # print(gcs_client.create_bucket(processed_bucket_name))
    
    # Grab A blob from the heap
    first_blob = gcs_client.pop_blob(bucket_name,patterns_file )
    if first_blob:
        print(f"First blob name: {first_blob.name}")
    
    
    #download to memory
    
    blob_data = gcs_client.download_blob_to_memory(bucket_name, first_blob.name)
    json_data = json.loads(blob_data)
    
    # print(blob_data[0:100])
    # create_gcs_bucket(gcs_client, bucket_name)
    
    results = json_data["results"]
    
    # Initialize lists to hold DataFrames
    df_main_list = []
    df_item_list = []
    df_resources_list = []
    df_call_number_list = []
    df_contributors_list = []
    df_subjects_list = []
    df_notes_list = []
    
    for result in results:
        df_main_list.append(normalize_main(result))
        df_item_list.append(normalize_item(result))
        df_resources_list.append(normalize_resources(result))
        df_call_number_list.append(normalize_call_numbers(result))
        df_contributors_list.append(normalize_contributors(result))
        df_subjects_list.append(normalize_subjects(result))
        df_notes_list.append(normalize_notes(result))
    
    # Concatenate all DataFrames
    df_main = pd.concat(df_main_list, ignore_index=True)
    df_item = pd.concat(df_item_list, ignore_index=True)
    df_resources = pd.concat(df_resources_list, ignore_index=True)
    df_call_number = pd.concat(df_call_number_list, ignore_index=True)
    df_contributors = pd.concat(df_contributors_list, ignore_index=True)
    df_subjects = pd.concat(df_subjects_list, ignore_index=True)
    df_notes = pd.concat(df_notes_list, ignore_index=True)
    
    # Define the BigQuery table schema
    # main_schema = [bigquery.SchemaField(name, bigquery.enums.SqlTypeNames.STRING) for name in df_main.columns]
    item_schema = [bigquery.SchemaField(name, bigquery.enums.SqlTypeNames.STRING) for name in df_item.columns]
    resources_schema = [bigquery.SchemaField(name, bigquery.enums.SqlTypeNames.STRING) for name in df_resources.columns]
    call_number_schema = [bigquery.SchemaField(name, bigquery.enums.SqlTypeNames.STRING) for name in df_call_number.columns]
    contributors_schema = [bigquery.SchemaField(name, bigquery.enums.SqlTypeNames.STRING) for name in df_contributors.columns]
    subjects_schema = [bigquery.SchemaField(name, bigquery.enums.SqlTypeNames.STRING) for name in df_subjects.columns]
    notes_schema = [bigquery.SchemaField(name, bigquery.enums.SqlTypeNames.STRING) for name in df_notes.columns]
    
    # Create BigQuery tables
    # bq_client.create_table(dataset_id, main_table_id, main_schema)
    bq_client.create_table(dataset_id, item_table_id, item_schema)
    bq_client.create_table(dataset_id, resources_table_id, resources_schema)
    bq_client.create_table(dataset_id, call_number_table_id, call_number_schema)
    bq_client.create_table(dataset_id, contributors_table_id, contributors_schema)
    bq_client.create_table(dataset_id, subjects_table_id, subjects_schema)
    bq_client.create_table(dataset_id, notes_table_id, notes_schema)
    
    # Load DataFrames into BigQuery tables
    # bq_client.load_dataframe_to_table(dataset_id, main_table_id, df_main)
    bq_client.load_dataframe_to_table(dataset_id, item_table_id, df_item)
    bq_client.load_dataframe_to_table(dataset_id, resources_table_id, df_resources)
    bq_client.load_dataframe_to_table(dataset_id, call_number_table_id, df_call_number)
    bq_client.load_dataframe_to_table(dataset_id, contributors_table_id, df_contributors)
    bq_client.load_dataframe_to_table(dataset_id, subjects_table_id, df_subjects)
    bq_client.load_dataframe_to_table(dataset_id, notes_table_id, df_notes)

    # Move the blob to the processed_results bucket
    gcs_client.copy_blob(bucket_name, first_blob.name, processed_bucket_name, first_blob.name)
    # gcs_client.delete_blob(bucket_name, first_blob.name)
    print(f"Blob {first_blob.name} moved to {processed_bucket_name} and deleted from {bucket_name}")

if __name__ == "__main__":
    main()

```

    trying creds file
    Buckets: ['loc-scraper', 'loc_flattener_processed', 'processed_results', 'smart-axis-421517_cloudbuild']
    Dataset supreme_court created.
    First valid blob selected: result-10.json
    First blob name: result-10.json
    Blob 'result-10.json' downloaded to memory.
    Table items_staging created in dataset supreme_court.
    Table resources_staging created in dataset supreme_court.
    Table call_numbers_staging created in dataset supreme_court.
    Table contributors_staging created in dataset supreme_court.
    Table subjects_staging created in dataset supreme_court.
    Table notes_staging created in dataset supreme_court.
    Loaded 70 rows into supreme_court:items_staging.
    Loaded 70 rows into supreme_court:resources_staging.
    Loaded 210 rows into supreme_court:call_numbers_staging.
    Loaded 138 rows into supreme_court:contributors_staging.
    Loaded 1570 rows into supreme_court:subjects_staging.
    Loaded 70 rows into supreme_court:notes_staging.
    Blob result-10.json moved to loc_flattener_processed and deleted from loc-scraper


#### Add while true logic and clean up the script

```Python
import os
import pandas as pd
import argparse
import json
import logging
from google.cloud import bigquery
from gcputils.gcpclient import GCSClient
from gcputils.GoogleCloudLogging import GoogleCloudLogging
from gcputils.BigQueryClient import BigQueryClient

def initialize_gcs_client(project_id, credentials_path=None):
    return GCSClient(project_id, credentials_path=credentials_path)

def initialize_google_cloud_logging_client(project_id, credentials_path=None):
    return GoogleCloudLogging(project_id, credentials_path=credentials_path)

def initialize_bq_client(project_id, credentials_path=None):
    return BigQueryClient(project_id, credentials_path=credentials_path)

def list_gcs_buckets(client):
    try:
        buckets = client.list_buckets()
        print("Buckets:", buckets)
        logging.info(f"Buckets: {buckets}")
    except Exception as e:
        logging.error(f"Error listing buckets: {e}")

def create_gcs_bucket(client, bucket_name):
    try:
        bucket = client.create_bucket(bucket_name=bucket_name)
        logging.info(bucket)
        print(bucket)
    except Exception as e:
        logging.error(f"Error creating bucket: {e}")

def normalize_main(result):
    df_main = pd.json_normalize(result)
    return df_main

def normalize_item(result):
    item_data = result['item']
    df_item = pd.json_normalize(item_data)
    df_item['id'] = result['id']  # Add 'id' for joining
    return df_item

def normalize_resources(result):
    resources_data = result['resources']
    df_resources = pd.json_normalize(resources_data)
    df_resources['id'] = result['id']  # Add 'id' for joining
    return df_resources

def normalize_call_numbers(result):
    item_data = result['item']
    call_numbers = item_data.get('call_number', [])
    df_call_number = pd.DataFrame(call_numbers, columns=['call_number'])
    df_call_number['id'] = result['id']  # Add 'id' for joining
    return df_call_number

def normalize_contributors(result):
    item_data = result['item']
    contributors = item_data.get('contributors', [])
    df_contributors = pd.DataFrame(contributors, columns=['contributors'])
    df_contributors['id'] = result['id']  # Add 'id' for joining
    return df_contributors

def normalize_subjects(result):
    item_data = result['item']
    subjects = item_data.get('subjects', [])
    df_subjects = pd.DataFrame(subjects, columns=['subjects'])
    df_subjects['id'] = result['id']  # Add 'id' for joining
    return df_subjects

def normalize_notes(result):
    item_data = result['item']
    notes = item_data.get('notes', [])
    df_notes = pd.DataFrame(notes, columns=['notes'])
    df_notes['id'] = result['id']  # Add 'id' for joining
    return df_notes

def create_tables_and_schemas(bq_client, bucket_name, patterns_file, gcs_client, dataset_id):
    # Define the BigQuery table schema
    main_table_id = "results_staging"
    item_table_id = "items_staging"
    resources_table_id = "resources_staging"
    call_number_table_id = "call_numbers_staging"
    contributors_table_id = "contributors_staging"
    subjects_table_id = "subjects_staging"
    notes_table_id = "notes_staging"

    # Assuming the first blob provides a sample structure
    sample_blob = gcs_client.pop_blob(bucket_name, patterns_file)
    blob_data = gcs_client.download_blob_to_memory(bucket_name, sample_blob.name)
    json_data = json.loads(blob_data)
    result = json_data["results"][0]  # Use the first result as a sample

    df_main = normalize_main(result)
    df_item = normalize_item(result)
    df_resources = normalize_resources(result)
    df_call_number = normalize_call_numbers(result)
    df_contributors = normalize_contributors(result)
    df_subjects = normalize_subjects(result)
    df_notes = normalize_notes(result)

    main_schema = [bigquery.SchemaField(name, bigquery.enums.SqlTypeNames.STRING) for name in df_main.columns]
    item_schema = [bigquery.SchemaField(name, bigquery.enums.SqlTypeNames.STRING) for name in df_item.columns]
    resources_schema = [bigquery.SchemaField(name, bigquery.enums.SqlTypeNames.STRING) for name in df_resources.columns]
    call_number_schema = [bigquery.SchemaField(name, bigquery.enums.SqlTypeNames.STRING) for name in df_call_number.columns]
    contributors_schema = [bigquery.SchemaField(name, bigquery.enums.SqlTypeNames.STRING) for name in df_contributors.columns]
    subjects_schema = [bigquery.SchemaField(name, bigquery.enums.SqlTypeNames.STRING) for name in df_subjects.columns]
    notes_schema = [bigquery.SchemaField(name, bigquery.enums.SqlTypeNames.STRING) for name in df_notes.columns]

    # Create BigQuery tables
    # bq_client.create_table(dataset_id, main_table_id, main_schema)
    bq_client.create_table(dataset_id, item_table_id, item_schema)
    bq_client.create_table(dataset_id, resources_table_id, resources_schema)
    bq_client.create_table(dataset_id, call_number_table_id, call_number_schema)
    bq_client.create_table(dataset_id, contributors_table_id, contributors_schema)
    bq_client.create_table(dataset_id, subjects_table_id, subjects_schema)
    bq_client.create_table(dataset_id, notes_table_id, notes_schema)

def process_blob(gcs_client, bq_client, bucket_name, processed_bucket_name, patterns_file, dataset_id):
    main_table_id = "results_staging"
    item_table_id = "items_staging"
    resources_table_id = "resources_staging"
    call_number_table_id = "call_numbers_staging"
    contributors_table_id = "contributors_staging"
    subjects_table_id = "subjects_staging"
    notes_table_id = "notes_staging"

    # Grab a blob from the heap
    first_blob = gcs_client.pop_blob(bucket_name, patterns_file)
    if not first_blob:
        return False

    print(f"Processing blob: {first_blob.name}")

    # Download to memory
    blob_data = gcs_client.download_blob_to_memory(bucket_name, first_blob.name)
    json_data = json.loads(blob_data)

    results = json_data["results"]

    # Initialize lists to hold DataFrames
    df_main_list = []
    df_item_list = []
    df_resources_list = []
    df_call_number_list = []
    df_contributors_list = []
    df_subjects_list = []
    df_notes_list = []

    for result in results:
        df_main_list.append(normalize_main(result))
        df_item_list.append(normalize_item(result))
        df_resources_list.append(normalize_resources(result))
        df_call_number_list.append(normalize_call_numbers(result))
        df_contributors_list.append(normalize_contributors(result))
        df_subjects_list.append(normalize_subjects(result))
        df_notes_list.append(normalize_notes(result))

    # Concatenate all DataFrames
    df_main = pd.concat(df_main_list, ignore_index=True)
    df_item = pd.concat(df_item_list, ignore_index=True)
    df_resources = pd.concat(df_resources_list, ignore_index=True)
    df_call_number = pd.concat(df_call_number_list, ignore_index=True)
    df_contributors = pd.concat(df_contributors_list, ignore_index=True)
    df_subjects = pd.concat(df_subjects_list, ignore_index=True)
    df_notes = pd.concat(df_notes_list, ignore_index=True)

    # Load DataFrames into BigQuery tables
    # bq_client.load_dataframe_to_table(dataset_id, main_table_id, df_main)
    bq_client.load_dataframe_to_table(dataset_id, item_table_id, df_item)
    bq_client.load_dataframe_to_table(dataset_id, resources_table_id, df_resources)
    bq_client.load_dataframe_to_table(dataset_id, call_number_table_id, df_call_number)
    bq_client.load_dataframe_to_table(dataset_id, contributors_table_id, df_contributors)
    bq_client.load_dataframe_to_table(dataset_id, subjects_table_id, df_subjects)
    bq_client.load_dataframe_to_table(dataset_id, notes_table_id, df_notes)

    # Move the blob to the processed_results bucket
    gcs_client.copy_blob(bucket_name, first_blob.name, processed_bucket_name, first_blob.name)
    gcs_client.delete_blob(bucket_name, first_blob.name)
    print(f"Blob {first_blob.name} moved to {processed_bucket_name} and deleted from {bucket_name}")

    return True

def main():
    parser = argparse.ArgumentParser(description='Run the script locally or in the cloud.')
    parser.add_argument('--local', action='store_true', help='Run the script locally with credentials path')
    args = parser.parse_args()

    dataset_id = "supreme_court"
    patterns_file = os.getenv('PATTERNS_FILE', 'exclude.txt')
    project_id = os.getenv('GCP_PROJECT_ID', 'smart-axis-421517')
    bucket_name = os.getenv('BUCKET_NAME', 'loc-scraper')
    processed_bucket_name = "processed_results"

    credentials_path = None
    if args.local:
        credentials_path = os.getenv('GCP_CREDENTIALS_PATH', 'secret.json')

    # Initialize logging
    logging_client = initialize_google_cloud_logging_client(project_id, credentials_path)
    logging_client.setup_logging()

    # List Buckets for testing
    gcs_client = initialize_gcs_client(project_id, credentials_path)
    list_gcs_buckets(gcs_client)

    # Create the processed_results bucket if not exists
    # gcs_client.create_bucket(processed_bucket_name)

    bq_client = initialize_bq_client(project_id, credentials_path)

    # Create the dataset if not exists
    bq_client.create_dataset(dataset_id)

    # Create tables and schemas
    create_tables_and_schemas(bq_client, bucket_name, patterns_file, gcs_client, dataset_id)
    # def create_tables_and_schemas(bq_client, bucket_name, patterns_file, gcs_client, dataset_id):

    # Process blobs in a loop
    while process_blob(gcs_client, bq_client, bucket_name, processed_bucket_name, patterns_file, dataset_id):
        print("Processed a blob, checking for more...")
        

if __name__ == "__main__":
    main()


```

### GCP Cloud Run 

I want this to run autonomously for me on GCP

To do this I will need to 

1. Create a DockerFile
2. Build the image on gcp
3. create a job to run it

### Create the DockerFile

My Dockerfile looks something like this. Ignore the quickstart code thta i've commente dout. I use that as a reference.

[GH Link](https://raw.githubusercontent.com/justin-napolitano/loc_normalizer/main/Dockerfile)


```yaml
# # Use the Alpine Linux base image
# FROM alpine:latest

# # Set the working directory inside the container
# WORKDIR /app

# # Copy a simple script that prints "Hello, World!" into the container
# COPY /src/hello.sh .

# # Make the script executable
# RUN chmod +x hello.sh

# # Define the command to run when the container starts
# CMD ["./hello.sh"]


# Use the official Python image from Docker Hub
FROM python:3.10-slim

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY ./src /app
COPY requirements.txt /app

# Install any needed dependencies specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Run the Python script when the container launches
CMD ["python", "loc_scraper.py"]
```


#### Using Cloudbuild

I want to automate the entire build and deploy process by passing the steps to google's cloud build service.  

My [file](https://github.com/justin-napolitano/loc_normalizer/blob/main/src/cloudbuild.yaml) looks like this...

```yaml

steps:
  - name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-t', 'gcr.io/$PROJECT_ID/$IMAGE_NAME', '.']
  - name: 'gcr.io/cloud-builders/docker'
    args: ['push', 'gcr.io/$PROJECT_ID/$IMAGE_NAME']
  - name: 'gcr.io/cloud-builders/gcloud'
    args: ['run', 'deploy', '$SERVICE_NAME',
           '--image', 'gcr.io/$PROJECT_ID/$IMAGE_NAME',
           '--platform', 'managed',
           '--region', '$REGION',
           '--allow-unauthenticated']

substitutions:
  _PROJECT_ID: 'smart-axis-421517'
  _IMAGE_NAME: 'loc-flattener-image'
  _SERVICE_NAME: 'loc-flattener'
  _REGION: 'us-west2'  # e.g., us-central1

timeout: '1200s'
```

#### Submit the build

To sbumit the build run the following from the cli or save to as script.

```bash
gcloud builds submit --config cloudbuild.yaml .
```


```python

```
