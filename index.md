---
slug: github-jnapolitano-site
title: Technical Overview of jnapolitano-site Implementation
repo: justin-napolitano/jnapolitano-site
githubUrl: https://github.com/justin-napolitano/jnapolitano-site
generatedAt: '2025-11-23T09:10:15.993354Z'
source: github-auto
summary: >-
  Explore the architecture, build system, and deployment details of the
  jnapolitano-site, a performant static site using Docker and Markdown.
tags:
  - docker
  - static-site
  - makefile
  - multi-architecture
  - zola
  - bash-scripting
  - static site generator
  - markdown
  - docker-compose
  - devops
  - site configuration
seoPrimaryKeyword: jnapolitano-site implementation
seoSecondaryKeywords:
  - static site architecture
  - docker build automation
  - content management workflows
  - multi-architecture Docker
  - site deployment strategies
seoOptimized: true
topicFamily: automation
topicFamilyConfidence: 0.9
topicFamilyNotes: >-
  The post focuses heavily on containerized build and deployment workflows,
  Makefile automation, scripts for content management, and multi-architecture
  Docker builds which are best captured under 'automation'. While the site is a
  static blog, the workflow and automation aspects dominate the technical
  content.
kind: project
id: github-jnapolitano-site
---

# jnapolitano-site: Technical Overview and Implementation Details

## Motivation and Problem Statement

This project serves as the personal website and blog for Justin Napolitano. The primary goal is to maintain a performant, easily deployable static site with content managed in Markdown and rendered to HTML. The site needs to support both development and production environments with minimal friction, including local testing and live deployment.

## Architecture and Build System

The site is structured as a static content repository, likely using a static site generator such as Zola (inferred from the Makefile's use of `ZOLA_BASE_URL`). Content is organized under the `site` directory, with Markdown files for posts and pages.

Containerization is central to the build and deployment process. A Dockerfile defines the image build, and Docker Compose orchestrates running the site as a container. The Makefile abstracts common workflows, allowing easy switching between development and production modes by setting environment variables and build arguments.

The Makefile defines targets for building, rebuilding (no cache), running, logging, and pushing multi-architecture images. It manages base URLs dynamically based on the mode (`dev` or `prod`), enabling the site to be tested locally with a local IP address or deployed with the production domain baked in.

## Deployment and Runtime

The `docker-compose.yml` defines a single service named `blog` that builds from the current directory and exposes port 8082 mapped to container port 80. It restarts automatically unless stopped.

Scripts such as `add_post.sh` and `update_posts.sh` automate content management tasks, while `setup_github_dns.sh` likely facilitates DNS configuration for GitHub Pages or similar hosting.

Multi-architecture image support is implemented using Docker Buildx, allowing the image to run on both amd64 and arm64 platforms.

## Content and Site Configuration

Content files under `site/content` use front matter with metadata such as `title`, `description`, `tags`, `categories`, and custom parameters. Posts include features like table of contents, copy buttons for code blocks, and outdate alerts to indicate stale content.

RSS feed customization is supported via Hugo-compatible XML templates, enabling integration with external systems such as a MySQL database for post metadata ingestion.

## Interesting Implementation Details

- The Makefile uses conditional logic to select base URLs and image tags based on the mode, simplifying environment management.
- The use of multi-arch Docker builds ensures portability across diverse hardware.
- Content metadata is richly annotated to support features like recent posts, author info, and social links.
- The project contains scripts for DNS setup and post management, indicating an automated content workflow.

## Practical Considerations

When returning to this project, focus first on the Makefile and Docker Compose setup to understand the build and deployment flow. Review the `site` directory for content structure and metadata conventions. The automation scripts provide entry points for content updates and infrastructure configuration.

The project assumes familiarity with Docker, static site generators (likely Zola or Hugo), and Bash scripting. The production deployment is designed to be reproducible and environment-aware.

## Summary

This repository encapsulates a containerized static site with automated build and deployment workflows, rich content metadata, and support for multi-environment configurations. It is a practical setup for managing a personal blog with modern DevOps practices and static site generation.

---

*This document is intended as a technical reference for developers and engineers revisiting the project.*

