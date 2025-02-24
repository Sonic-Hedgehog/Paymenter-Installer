#!/bin/bash

# Define the repository URL
REPO_URL="https://raw.githubusercontent.com/Sonic-Hedgehog/Paymenter-Installer/main"
COLOR_SCRIPT_URL="$REPO_URL/core/color_generator.sh"
OS_CHECKER_URL="$REPO_URL/core/os_checker.sh"

# Load color generator
if source <(curl -fsSL "$COLOR_SCRIPT_URL"); then
    log_info "Color generator loaded successfully."
else
    echo -e "\033[0;31m[ERROR]\033[0m Failed to load color generator. Exiting."
    exit 1
fi

# Load and execute OS checker
if source <(curl -fsSL "$OS_CHECKER_URL"); then
    log_info "OS checked successfully."
else
    log_error "Failed to load OS checker. Please check your network connection and try again."
    exit 1
fi

