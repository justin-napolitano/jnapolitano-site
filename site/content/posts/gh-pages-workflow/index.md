+++
title =  "Hugo Build and Deploy GH Workflow"
date = "2024-06-11"
description = "Hugo Build GH Workflow"
author = "Justin Napolitano"
tags = ['git', 'python', 'submodules', 'automation','workflow']
images = ["images/feature-hugo.png"]
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


# Creating a GH Workflow to Build and Deploy a hugo site to gh-pages

## Why

To simplify the build process.  


## Creating the Workflow

### create your yaml config file

```bash
touch hugo.yaml
```

### Set the trigger and the environment defaults


The code below creates a trigger on push from the main and the gh-pages branches.  It also sets read and write permissions to permit executing code and building hugo.  

```yaml
on:
  # Runs on pushes targeting the default branch
  push:
    branches:
      - main
      # - pit
      # - ghpages
      - gh-pages

  # Allows you to run this workflow manually from the Actions tab
  workflow_dispatch:

# Sets permissions of the GITHUB_TOKEN to allow deployment to GitHub Pages
permissions:
  contents: read
  pages: write
  id-token: write

# Allow only one concurrent deployment, skipping runs queued between the run in-progress and latest queued.
# However, do NOT cancel in-progress runs as we want to allow these production deployments to complete.
concurrency:
  group: "pages"
  cancel-in-progress: false

# Default to bash
defaults:
  run:
    shell: bash
```

### Define the jobs

There will be 2 jobs in this workflow

* The build job
* The Deploy job 

#### Build job 

* Runs an ubuntu vm 
* Install Hugo from scrip 
* installs dart sass 
* setsup pages
* configures pages using the gh defaults flow
* installs node.js dependencies to host and build js modules within most sites
* hugo build to actually build the site
* upload the artifact to gh pages for hosting


#### The Deploy job

* Runs on an ubuntu vm
* runs the gh deploy pages action ```actions/deploy-pages@v4```

#### Code 

```yaml
jobs:
  # Build job
  build:
    runs-on: ubuntu-latest
    env:
      HUGO_VERSION: 0.124.0
    steps:
      - name: Install Hugo CLI
        run: |
          wget -O ${{ runner.temp }}/hugo.deb https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.deb \
          && sudo dpkg -i ${{ runner.temp }}/hugo.deb          
      - name: Install Dart Sass
        run: sudo snap install dart-sass
      - name: Checkout
        uses: actions/checkout@v4
        with:
          submodules: recursive
          fetch-depth: 0
      - name: Setup Pages
        id: pages
        uses: actions/configure-pages@v4
      - name: Install Node.js dependencies
        run: "[[ -f package-lock.json || -f npm-shrinkwrap.json ]] && npm ci || true"
      - name: Build with Hugo
        env:
          # For maximum backward compatibility with Hugo modules
          HUGO_ENVIRONMENT: production
          HUGO_ENV: production
        run: |
          hugo \
            --gc \
            --minify \
            --baseURL "${{ steps.pages.outputs.base_url }}/"          
      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: ./public

  # Deployment job
  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```


### Full Document

Find the most up to date file here ```https://github.com/justin-napolitano/gh-pages-workflow.git```

## Integrating the hugo build jobs into your workflow 

From your hugo project root

### Initialize a git repo if not already done

```bash
git init && git add . && git commit -m "initialize' 

```

### Push to remote

I use the gh cli.  Follow the official gh documentation to install [Official Documentation]("https://cli.github.com/manual/)

Run the following and follow the prompts.  

```bash
gh repo create
```

### Make the workflow directory

From the git root run the following.

```bash
mkdir .github/workflows
```

### Copy the hugo file to the directory 

In my case I will just download the file that have already created and maintain by running the following from repo root. 

```bash
cd .github/workflows && wget https://raw.githubusercontent.com/justin-napolitano/gh-pages-workflow/main/hugo.yaml && cd ../.. 
```

### Push

```bash
git add . && git commit -m "creating the hugo build workflow" && git push 
```
