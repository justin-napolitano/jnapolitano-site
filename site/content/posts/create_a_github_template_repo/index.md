
+++
title= "Using GitHub Template Repositories to Automate Script Deployment"
#date: 2024-06-27T12:00:00Z
draft= false
tags= ["GitHub", "Automation", "Templates", "Scripting"]
categories= ["Projects"] 
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

# Using GitHub Template Repositories to Automate Script Deployment

Managing multiple repositories can be a challenge, especially when you need to ensure that each one includes certain common scripts or configurations. GitHub's template repositories feature can help streamline this process. In this post, we'll walk through how to use a template repository to automatically include a `gh_submodule_sync.sh` script in every new repository you create.

## Prerequisites

- **GitHub CLI**: Ensure you have the GitHub CLI installed. You can find installation instructions [here](https://cli.github.com/).
- **Existing Repository**: We'll use an existing repository `gh_submodule_sync` as the template.

## Step 1: Clone the Repository

First, clone your existing repository:

```sh
git clone https://github.com/justin-napolitano/gh_submodule_sync.git
cd gh_submodule_sync
```

## Step 2: Mark the Repository as a Template

Next, mark your repository as a template using the GitHub CLI:

```sh
gh api -X PATCH /repos/justin-napolitano/gh_submodule_sync -f is_template=true
```

This command sets the `is_template` flag to `true`, designating your repository as a template.

## Step 3: Create New Repositories from the Template

You can now create new repositories using your template. Here's how to do it:

```sh
gh repo create new-repo --template=justin-napolitano/gh_submodule_sync --public --confirm
```

Replace `new-repo` with the name of your new repository. This command creates a new repository based on your template.

## Step 4: Clone the New Repository

Finally, clone your new repository to your local machine:

```sh
git clone https://github.com/justin-napolitano/new-repo.git
cd new-repo
```

Your new repository will include all the contents of the template repository, including the `gh_submodule_sync.sh` script.
