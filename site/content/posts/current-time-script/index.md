+++
title =  "Current Time Script"
description = "An easy way to expor the current time" 
author = "Justin Napolitano"
tags = ["scripting","bash"]
images = ["images/feature-image.png"]
date = "2024-07-13T16:25:59-05:00"
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

# Current Time Script

This script returns the current date and time in the format `date = "2024-07-13T14:27:45-06:00"`.

## Prerequisites

- Bash shell
- `date` command (available on most Unix-like systems)

## Usage

1. **Save the Script:**

   Save the following script to a file, e.g., `current_time.sh`:

   ```bash
   #!/bin/bash

   # Get the current date and time in the desired format
   current_time=$(date +"%Y-%m-%dT%H:%M:%S%z")

   # Format the time zone offset with a colon
   formatted_time="${current_time:0:22}:${current_time:22:2}"

   # Print the result
   echo "date = \"$formatted_time\""
   ```

2. **Make the Script Executable:**

   Run the following command to make the script executable:

   ```bash
   chmod +x current_time.sh
   ```

3. **Run the Script:**

   Execute the script using the following command:

   ```bash
   ./current_time.sh
   ```

   The output will be the current date and time in the specified format, e.g.:

   ```
   date = "2024-07-13T14:27:45-06:00"
   ```

## License

This script is provided as-is without any warranty. Feel free to modify and use it as needed.
