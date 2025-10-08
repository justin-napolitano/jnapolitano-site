+++
title =  "Update All Repos Bash Script"
description = "Utility script to update all repos wihtin a directory." 
author = "Justin Napolitano"
tags = ["scripting","bash"]
images = ["images/feature-image.png"]
date = "2024-07-13"
categories = ["projects"]
series = ["bash"]
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

# Update Repositories Script

This script recursively finds all git repositories in a specified directory and pulls the latest changes for each one.

## Prerequisites

- Bash shell
- Git installed
- Proper permissions to access and modify the repositories

## Installation

1. **Create the script**:
   Save the following script to a file named `update_repos.sh`:

   ```bash
   #!/bin/bash

   # Define the default root directory where your repos are located
   DEFAULT_ROOT_DIR="/home/cobra/Repos"

   # Use the provided argument as the root directory, or the default if none is provided
   ROOT_DIR=${1:-$DEFAULT_ROOT_DIR}

   echo "Starting update process for repositories in $ROOT_DIR"

   # Function to pull changes in a git repository
   pull_repo() {
       local repo_dir=$1
       echo "Pulling updates in $repo_dir"
       cd "$repo_dir" || return
       git pull
       echo "Completed update in $repo_dir"
       cd - || return
   }

   # Export the function so it can be used by find -exec
   export -f pull_repo

   # Find all .git directories and pull changes in their parent directories
   find "$ROOT_DIR" -name ".git" -type d -exec bash -c 'pull_repo "$(dirname "{}")"' \;

   echo "All repositories updated."
   ```

2. **Make the script executable**:
   ```bash
   chmod +x update_repos.sh
   ```

3. **Move the script to `/usr/local/bin`**:
   ```bash
   sudo mv update_repos.sh /usr/local/bin/update_repos
   ```

4. **Verify the script is accessible**:
   You can now run the script from anywhere by simply typing `update_repos` in the terminal.

## Usage

1. Open a terminal.
2. Run the script by typing:
   ```bash
   update_repos [path_to_repos]
   ```

   - If no path is provided, it defaults to `/home/cobra/Repos`.

The script will find all `.git` directories in the specified root directory and pull the latest changes for each repository. It will provide status updates during the process.

## License

This project is licensed under the MIT License.
