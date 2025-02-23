#!/bin/bash

# Load color generator if not already loaded
if [ -z "$BLUE" ]; then
    eval "$(curl -fsSL "https://raw.githubusercontent.com/Sonic-Hedgehog/paymenter-installer/main/utils/color-generator.sh")"
fi

# Function to gather system information
gather_system_info() {
    OS_NAME=$(lsb_release -si 2>/dev/null || grep '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
    OS_VERSION=$(lsb_release -sr 2>/dev/null || grep '^VERSION_ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
    ARCHITECTURE=$(uname -m)
    KERNEL_VERSION=$(uname -r)
}

# Function to report an error
log_error_report() {
    local error_message="$1"
    local error_context="$2"
    local error_action="$3"

    # Gather system information
    gather_system_info

    echo -e "${RED}[ERROR]${NC} $error_message"
    echo -e "${YELLOW}[SYSTEM INFORMATION]${NC}"
    echo "  Operating System: $OS_NAME"
    echo "  Version: $OS_VERSION"
    echo "  Architecture: $ARCHITECTURE"
    echo "  Kernel: $KERNEL_VERSION"
    echo "  Check: $error_context"
    echo "  Action: $error_action"
    
    echo -e "${BLUE}[INFO]${NC} Please report this issue on GitHub or Discord and provide the log above."
}
