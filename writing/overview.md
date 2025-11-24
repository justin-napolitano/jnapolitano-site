---
slug: github-jnapolitano-site-writing-overview
id: github-jnapolitano-site-writing-overview
title: 'Behind the Scenes of My Personal Site: jnapolitano-site'
repo: justin-napolitano/jnapolitano-site
githubUrl: https://github.com/justin-napolitano/jnapolitano-site
generatedAt: '2025-11-24T17:34:49.166Z'
source: github-auto
summary: >-
  I decided to create a personal site and blog to share my thoughts and
  projects. Enter `jnapolitano-site`. It’s the go-to repository that holds the
  source code and deployment setup for the site. Let’s dig into what this
  project is all about, why I built it, and how I’ve slapped it all
  together—along with some thoughts on what I’d like to tackle next.
tags: []
seoPrimaryKeyword: ''
seoSecondaryKeywords: []
seoOptimized: false
topicFamily: null
topicFamilyConfidence: null
kind: writing
entryLayout: writing
showInProjects: false
showInNotes: false
showInWriting: true
showInLogs: false
---

I decided to create a personal site and blog to share my thoughts and projects. Enter `jnapolitano-site`. It’s the go-to repository that holds the source code and deployment setup for the site. Let’s dig into what this project is all about, why I built it, and how I’ve slapped it all together—along with some thoughts on what I’d like to tackle next.

## What is jnapolitano-site?

At its core, `jnapolitano-site` is a static website powered by helpful tools and clean code. I primarily use HTML for content, but there's a rich back-end set up as well. The site is Dockerized, which means it runs in containers. This setup makes deploying my site a breeze, whether I'm working locally or putting it live.

### Why Does It Exist?

I needed a space where I could document my adventures in tech, share insights, and maybe help others along the way. There’s a lot of noise out there, but I wanted a simple, personal touch. I’m a fan of writing in Markdown, and having a static site saves me from the hassle of complex back-end setups. Plus, Docker gave me a consistent environment across different machines—always a win.

## Key Design Decisions

A few key design choices helped shape this project:

- **Static Site Generation**: I opted for static site content management. This keeps the site fast and straightforward. After checking out various tools, I leveraged Hugo initially, but it seems Zola has snuck in there too (I’m still fine-tuning that side of things).
  
- **Containerization**: By using Docker and Docker Compose, I ensured that both my development and production environments are the same. This minimizes "works on my machine" issues—a must for any developer.

- **Automation Scripts**: I built scripts for tasks like adding and updating posts, as well as DNS setup. Automating these processes saves me time and energy.

## Tech Stack

I put together quite the toolkit for this project:

- **HTML**: The backbone language to craft my site content.
- **Docker & Docker Compose**: For containerization and orchestration. This setup lets me manage the deployment like a boss.
- **Bash Scripting**: I rely on Bash scripts to automate repetitive tasks, making life easier.
- **Zola**: My preferred static site generator—though Hugo is still in the mix for now.

These tools work in harmony to deliver a seamless experience both for me and the visitors.

## Getting Started

If you're interested in checking it out or contributing, here’s how to get started:

### Prerequisites

- You need Docker and Docker Compose set up on your machine.
- A Bash shell is handy for running some scripts.

### Clone the Repository

```bash
git clone https://github.com/justin-napolitano/jnapolitano-site.git
cd jnapolitano-site
```

### Build and Run the Site

The beauty of this setup is the simplicity in running the site. By default, it launches in production mode:

```bash
make up-prod
```

Want to tweak things for local development? Use:

```bash
make up-dev
```

To rebuild everything from scratch (because sometimes that’s just necessary), run:

```bash
make rebuild-prod
# or
make rebuild-dev
```

Need to stop the containers or view the logs? The commands are just as straightforward:

```bash
make down
make logs
```

These commands are incredibly user-friendly, making management a breeze.

### Additional Scripts

Here are a few scripts that come in handy:

- `add_post.sh`: Kick your new blog posts into gear.
- `update_posts.sh`: Keep existing posts fresh.
- `setup_github_dns.sh`: Configure DNS for GitHub Pages—because who wants to mess around with that manually?

## Project Structure

Here’s a peek at the structure within the repository:

```
.
├── add_post.sh            # Scripts to manage posts
├── Caddyfile              # Web server configuration
├── docker-compose.yml     # Docker Compose configuration
├── Dockerfile             # Docker image build instructions
├── Makefile               # Commands for build and deployment
├── setup_github_dns.sh    # DNS setup script
├── site/                  # Contains static site content
│   └── content/           # Markdown files for posts/pages
├── update_posts.sh        # Script to manage post updates
├── zz_dockerfile          # Experimental or backup Dockerfile
└── zz_Makefile            # Experimental or backup Makefile
```

Having everything structured this way makes it easy to find what I need quickly.

## Future Work / Roadmap

I’ve got some dreams for this project, and I’m excited about the road ahead:

- **Site Metadata**: Enhance the site with better descriptions and metadata for improved SEO.
- **Automated Deployments**: Integrate CI/CD pipelines to streamline deployments to GitHub Pages or other platforms.
- **Multi-Language Support**: I’d like to eventually support multiple languages—targeting a broader audience is always nice.
- **Accessibility Enhancements**: It's crucial that everyone can navigate this site effortlessly.
- **Documentation**: Improving the documentation for automation scripts is high on my list. Clearer guides can help others use it effectively.

## Connect with Me

If you're curious about updates, insights, or general musings, I share them on social media platforms like Mastodon, Bluesky, and Twitter/X. Feel free to reach out—I love connecting with fellow devs and anyone interested in this journey!

That's a wrap on the scoop about `jnapolitano-site`. Thanks for reading!
