#!/bin/bash

# Define the repository URL
REPO_URL="https://raw.githubusercontent.com/Sonic-Hedgehog/Paymenter-Installer/main"

# Load OS Checker as a subscript
source <(curl -fsSL "$REPO_URL/core/oschecker.sh")

# Check if oschecker exited with an error
if [ $? -ne 0 ]; then
    echo "[ERROR] OS Checker encountered an issue. Exiting."
    exit 1
fi

# Check if INSTALL_SCRIPT variable is set
if [ -n "$INSTALL_SCRIPT" ]; then
    echo "[INFO] Using installation script: $INSTALL_SCRIPT"
    source <(curl -fsSL "$SCRIPT_URL")

else
    echo "[ERROR] No compatible installation script found. Exiting."
    exit 1
fi