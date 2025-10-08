+++
title =  "Signal Desktop Installation Script"
description = "Install Signal on Debian Devices"
author = "Justin Napolitano"
tags = ["linux","ubuntu"]
categories = ['projects']
images = ["images/feature-image.png"]
date = "2024-07-09"
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


# Signal Desktop Installation Script

This script automates the process of installing Signal Desktop on 64-bit Debian-based Linux distributions such as Ubuntu and Mint.

## Prerequisites

- A 64-bit Debian-based Linux distribution (e.g., Ubuntu, Mint)
- Administrative (sudo) privileges

## Script Overview

The script performs the following steps:

1. Installs the official Signal public software signing key.
2. Adds the Signal repository to the system's list of repositories.
3. Updates the package database and installs Signal Desktop.

## Usage Instructions

### Step 1: Save the Script

Save the following script to a file, e.g., `install_signal.sh`:

\`\`\`bash
#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# 1. Install the official public software signing key
echo "Installing the Signal public software signing key..."
wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg
cat signal-desktop-keyring.gpg | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null

# 2. Add the Signal repository to the list of repositories
echo "Adding the Signal repository to the list of repositories..."
echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' |\
  sudo tee /etc/apt/sources.list.d/signal-xenial.list

# 3. Update the package database and install Signal
echo "Updating the package database..."
sudo apt update

echo "Installing Signal Desktop..."
sudo apt install -y signal-desktop

echo "Signal Desktop installation completed successfully!"
\`\`\`

### Step 2: Make the Script Executable

Open a terminal and navigate to the directory where the script is saved. Run the following command to make the script executable:

\`\`\`bash
chmod +x install_signal.sh
\`\`\`

### Step 3: Execute the Script

Run the script with the following command:

\`\`\`bash
./install_signal.sh
\`\`\`

## Troubleshooting

- Ensure you have a stable internet connection.
- Verify that you have administrative (sudo) privileges.
- If you encounter any errors, read the error messages carefully and ensure that all steps are followed correctly.

## Additional Information

For more information about Signal Desktop and its installation process, visit the [official Signal website](https://signal.org/download/).

---

**Note:** This script and documentation are intended for users with basic knowledge of using the terminal and running scripts on Linux systems. Always review and understand scripts before executing them on your system.
