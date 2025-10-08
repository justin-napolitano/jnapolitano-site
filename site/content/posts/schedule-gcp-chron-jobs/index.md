+++
title =  "Schedule a GCP Cloud Run Chron Job"
date = "2024-07-16T17:23:06-05:00"
description = "Scheduling jobs to run every hour"
author = "Justin Napolitano"
tags = ['gcp','bash','cli']
images = ["images/feature-image.png"]
categories = ['projects']
series = ['gcp']
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


# How to Schedule a Cloud Run Job Using Google Cloud Scheduler

In this tutorial, we'll walk through the process of scheduling a job in Google Cloud Run using Google Cloud Scheduler. This is particularly useful for tasks that need to run at regular intervals, such as data processing, periodic updates, or maintenance tasks.

## Prerequisites

Before we start, ensure you have the following:
- A Google Cloud project.
- `gcloud` command-line tool installed and authenticated.
- Necessary permissions to create Cloud Run jobs and Cloud Scheduler jobs.
- A Dockerfile to build your container image.

## Step 1: Create a Cloud Run Job

First, you need to create a Cloud Run job. This involves creating a container image and deploying it as a job in Cloud Run.

### 1. Create a Dockerfile

Here is a simple example of a Dockerfile that runs a Python script:

\`\`\`dockerfile
FROM python:3.8-slim

COPY script.py /script.py

CMD ["python", "/script.py"]
\`\`\`

### 2. Build and Push the Docker Image

Use the following `gcloud` commands to build and push your Docker image to Google Container Registry:

\`\`\`bash
# Set variables
PROJECT_NAME="your-project-name"
IMAGE_NAME="your-image-name"
TAG="latest"
REGION="us-west2"

# Build the Docker image
gcloud builds submit --tag gcr.io/$PROJECT_NAME/$IMAGE_NAME:$TAG

# Deploy the Cloud Run job
gcloud run jobs create $IMAGE_NAME-job \
    --image gcr.io/$PROJECT_NAME/$IMAGE_NAME:$TAG \
    --region $REGION
\`\`\`

## Step 2: Schedule the Job Feel free to Using Google Cloud Scheduler

Now, we’ll create a Cloud Scheduler job to trigger the Cloud Run job at regular intervals. In this example, we will schedule the job to run every hour.

### 1. Create the Scheduler Job

Run the following `gcloud` command to create a Cloud Scheduler job:

\`\`\`bash
gcloud scheduler jobs create http python-rss-reader-scheduler \
    --schedule="0 * * * *" \
    --uri="https://$REGION-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/$PROJECT_NAME/jobs/$IMAGE_NAME-job:run" \
    --http-method="POST" \
    --time-zone="UTC" \
    --oidc-service-account-email="general-purpose-account@$PROJECT_NAME.iam.gserviceaccount.com" \
    --location="$REGION"
\`\`\`

### Explanation

- `--schedule="0 * * * *"`: This cron expression schedules the job to run every hour.
- `--uri`: The endpoint to trigger the Cloud Run job.
- `--http-method="POST"`: The HTTP method to use when making the request.
- `--time-zone="UTC"`: The time zone for the scheduler.
- `--oidc-service-account-email`: The service account email to use for authentication.
- `--location`: The location of the scheduler job.

## Step 3: Verify the Scheduler Job

To ensure the scheduler job is set up correctly, you can list your Cloud Scheduler jobs:

\`\`\`bash
gcloud scheduler jobs list --location $REGION
\`\`\`

You should see your `python-rss-reader-scheduler` job listed.

## Summary

In this tutorial, we covered how to schedule a Cloud Run job using Google Cloud Scheduler. By following these steps, you can automate tasks to run at regular intervals, improving the efficiency and reliability of your applications.

Modify the cron expression and other parameters to suit your specific needs.
