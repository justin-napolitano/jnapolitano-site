---
slug: github-jnapolitano-site-note-technical-overview
id: github-jnapolitano-site-note-technical-overview
title: jnapolitano-site
repo: justin-napolitano/jnapolitano-site
githubUrl: https://github.com/justin-napolitano/jnapolitano-site
generatedAt: '2025-11-24T18:39:36.244Z'
source: github-auto
summary: >-
  This repo is my personal site and blog setup. It’s built with HTML and runs in
  Docker. I use Docker Compose for deployment.
tags: []
seoPrimaryKeyword: ''
seoSecondaryKeywords: []
seoOptimized: false
topicFamily: null
topicFamilyConfidence: null
kind: note
entryLayout: note
showInProjects: false
showInNotes: true
showInWriting: false
showInLogs: false
---

This repo is my personal site and blog setup. It’s built with HTML and runs in Docker. I use Docker Compose for deployment.

## Key Features
- Static site content in the `site` directory managed with Hugo or a similar tool.
- Dockerized for multi-architecture with environment configs.
- Scripts to manage posts and DNS setup.
- MySQL database integration and RSS feed support.

## Quick Start

### Prerequisites
- Have Docker and Docker Compose installed.
- Use a Bash shell to run scripts.

### Clone the Repo
```bash
git clone https://github.com/justin-napolitano/jnapolitano-site.git
cd jnapolitano-site
```

### Build and Run
Default runs in production. To build:
```bash
make up-prod
```
For development mode:
```bash
make up-dev
```

### Stop Containers
```bash
make down
```

### Important Scripts
- `add_post.sh`: Add new posts.
- `update_posts.sh`: Update existing posts.
- `setup_github_dns.sh`: DNS setup for GitHub pages.
