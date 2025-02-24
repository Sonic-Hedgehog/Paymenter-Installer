#!/bin/bash

# Define the repository URL
REPO_URL="https://raw.githubusercontent.com/Sonic-Hedgehog/Paymenter-Installer/main"
INSTALL_SCRIPT_URL="$REPO_URL//install_node_npm.sh"
COLOR_SCRIPT_URL="$REPO_URL/core/color-generator.sh"

# Load color generator
echo $COLOR_SCRIPT_URL
source <(curl -fsSL "$COLOR_SCRIPT_URL")

# Fetch the supported Node.js version from JSON
SUPPORTED_VERSION=$(curl -fsSL "$REPO_URL/core/supported_nodejs_version.json" | jq -r '.version')

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    log_error "'jq' is required but not installed. Please install it first."
    exit 1
fi

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    log_error "Node.js is not installed. Please install it first."
    read -p "Would you like to install Node.js and npm now? (y/n): " choice
    if [[ "$choice" == "y" ]]; then
        source <(curl -fsSL "$INSTALL_SCRIPT_URL")
    else
        exit 1
    fi
fi

# Get installed Node.js version
INSTALLED_NODE_VERSION=$(node -v | sed 's/v//')

# Compare Node.js versions
if [[ "${INSTALLED_NODE_VERSION%%.*}" -ge "${SUPPORTED_VERSION}" ]]; then
    log_success "Node.js version $INSTALLED_NODE_VERSION is supported."
else
    log_error "Node.js version $INSTALLED_NODE_VERSION is not supported. Minimum required version is $SUPPORTED_VERSION."
    read -p "Would you like to install the required version now? (y/n): " choice
    if [[ "$choice" == "y" ]]; then
        source <(curl -fsSL "$INSTALL_SCRIPT_URL")
    else
        exit 1
    fi
fi

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    log_error "npm is not installed. Please install it first."
    read -p "Would you like to install npm now? (y/n): " choice
    if [[ "$choice" == "y" ]]; then
        source <(curl -fsSL "$INSTALL_SCRIPT_URL")
    else
        exit 1
    fi
fi

# Get installed npm version
INSTALLED_NPM_VERSION=$(npm -v)
log_success "npm version $INSTALLED_NPM_VERSION is installed."

exit 0
