# jnapolitano-site

This repository contains the source and deployment setup for Justin Napolitano's personal site and blog. It is built primarily with HTML and uses Docker and Docker Compose for containerized development and production deployment.

## Features

- Static site content managed under the `site` directory using Hugo or a similar static site generator.
- Dockerized build and deployment with multi-architecture support.
- Environment-specific configurations for development and production.
- Scripts for managing posts and DNS setup.
- Integration with a MySQL database and RSS feed support (implied from content).

## Tech Stack

- HTML (primary language for site content)
- Docker & Docker Compose (containerization and orchestration)
- Bash scripting (automation scripts for posts and DNS)
- Zola (static site generator, inferred from Makefile build args)

## Getting Started

### Prerequisites

- Docker and Docker Compose installed
- Bash shell for running scripts

### Clone the repository

```bash
git clone https://github.com/justin-napolitano/jnapolitano-site.git
cd jnapolitano-site
```

### Build and run the site

By default, the site runs in production mode with the base URL set to https://jnapolitano.com.

To build and start the site:

```bash
make up-prod
```

To start in development mode (with local IP base URL):

```bash
make up-dev
```

To rebuild the image from scratch (no cache):

```bash
make rebuild-prod
# or
make rebuild-dev
```

To stop the containers:

```bash
make down
```

To view logs:

```bash
make logs
```

### Additional scripts

- `add_post.sh`: Script to add new posts.
- `update_posts.sh`: Script to update existing posts.
- `setup_github_dns.sh`: Script to configure DNS for GitHub pages.

## Project Structure

```
.
├── add_post.sh            # Script to add new posts
├── Caddyfile              # Web server configuration
├── docker-compose.yml     # Docker Compose configuration
├── Dockerfile             # Docker image build instructions
├── Makefile               # Build and deployment commands
├── setup_github_dns.sh    # DNS setup script
├── site/                  # Static site content
│   └── content/           # Markdown content for posts and pages
├── update_posts.sh        # Script to update posts
├── zz_dockerfile          # Possibly experimental or backup Dockerfile
└── zz_Makefile            # Possibly experimental or backup Makefile
```

## Future Work / Roadmap

- Add a detailed site description and metadata.
- Automate deployment to GitHub Pages or other hosting platforms.
- Integrate continuous integration/continuous deployment (CI/CD) pipelines.
- Enhance multi-language support and accessibility.
- Improve documentation for post automation scripts.

---

*Note: This README assumes the use of Zola as the static site generator based on build arguments in the Makefile. Adjust accordingly if another generator is used.*