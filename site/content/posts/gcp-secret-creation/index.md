+++
title =  "GCP Secret Manager Script"
date = "2024-07-18T12:25:11-05:00"
description = "GCP Secret Manager secret automation"
author = "Justin Napolitano"
tags = ['python', "gcp","programming"]
images = ["images/feature-image.png"]
categories = ['Projects']
series = ["GCP"]
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

# GCP Secret Manager Script

This script manages secrets in Google Cloud Platform's Secret Manager. It can create, overwrite, and delete secrets based on the provided YAML configuration file and environment variables.

## Prerequisites

- Python 3.6 or higher
- Google Cloud SDK installed and authenticated
- Necessary Python packages installed (`google-cloud-secret-manager`, `python-dotenv`, `pyyaml`)

## Installation

1. **Clone the repository**:
    ```sh
    git clone https://github.com/justin-napolitano/gcp-secret-creation.py.git
    cd your-repo-directory
    ```

2. **Create a virtual environment and activate it**:
    ```sh
    python -m venv venv
    source venv/bin/activate  # On Windows, use `venv\\Scripts\\activate`
    ```

3. **Install the required packages**:
    ```sh
    pip install google-cloud-secret-manager python-dotenv pyyaml
    ```

## Setup

1. **Create a `.env` file** in the root directory with the following structure:
    ```env
    PROJECT_NAME=your_project_name
    FAKE_MASTODON_USERNAME=fake_username
    FAKE_MASTODON_PASSWORD=fake_password
    ```

2. **Create a `secrets.yaml` file** in the root directory with the following structure:
    ```yaml
    secrets:
      - id: "FAKE_MASTODON_USERNAME"
        env_var: "FAKE_MASTODON_USERNAME"
      - id: "FAKE_MASTODON_PASSWORD"
        env_var: "FAKE_MASTODON_PASSWORD"
    ```

## Usage

The script provides several command-line arguments to control its behavior.

### Arguments

- `--url`: Base URL for the API endpoint (default: `http://localhost:8080`)
- `--test`: Flag to delete secrets after testing
- `--overwrite`: Flag to overwrite existing secrets
- `--delete`: Flag to delete secrets specified in the YAML file
- `--secrets-file`: Path to the YAML file with secrets configuration (default: `secrets.yaml`)

### Running the Script

1. **Run the script without deleting or overwriting secrets**:
    ```sh
    python your_script.py --secrets-file secrets.yaml
    ```

2. **Run the script and delete secrets after testing**:
    ```sh
    python your_script.py --secrets-file secrets.yaml --test
    ```

3. **Run the script with the `--overwrite` flag to overwrite existing secrets**:
    ```sh
    python your_script.py --secrets-file secrets.yaml --overwrite
    ```

4. **Run the script to delete secrets specified in the YAML file**:
    ```sh
    python your_script.py --secrets-file secrets.yaml --delete
    ```

## Example

Here is an example of running the script to manage secrets:

```sh
python your_script.py --secrets-file secrets.yaml --overwrite --test
```
