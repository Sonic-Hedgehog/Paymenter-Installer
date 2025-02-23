#!/bin/bash

# Standard-Branch setzen (falls kein Argument übergeben wird)
installer_branch="main"

# Prüfen, ob ein Argument für den Branch übergeben wurde
if [ ! -z "$1" ]; then
    installer_branch="$1"
    echo -e "\e[34m[INFO]\e[0m Using branch: $installer_branch"
else
    echo -e "\e[34m[INFO]\e[0m No branch specified, using default branch: $installer_branch"
fi

# Prüfen, ob curl installiert ist
if ! command -v curl &> /dev/null; then
    echo -e "\e[31m[ERROR]\e[0m curl is not installed."

    # Frage den Benutzer, ob curl installiert werden soll
    read -p "Would you like to install curl? (y/n): " answer

    if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
        echo -e "\e[34m[INFO]\e[0m Installing curl..."

        if [ -f /etc/debian_version ]; then
            sudo apt-get update && sudo apt-get install -y curl
        elif [ -f /etc/redhat-release ]; then
            sudo yum install -y curl
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y curl
        else
            echo -e "\e[31m[ERROR]\e[0m Unsupported system for automatic curl installation."
            exit 1
        fi

        if command -v curl &> /dev/null; then
            echo -e "\e[32m[SUCCESS]\e[0m curl has been successfully installed!"
        else
            echo -e "\e[31m[ERROR]\e[0m Failed to install curl. Please install it manually and try again."
            exit 1
        fi
    else
        echo -e "\e[31m[ERROR]\e[0m curl is required to proceed. The script cannot continue without curl."
        exit 1
    fi
fi

# GitHub Repository URL für Skripte
REPO_URL="https://raw.githubusercontent.com/Sonic-Hedgehog/paymenter-installer/$installer_branch"

# Farbgenerator & Fehlerreporter direkt ausführen (ohne Speicherung)
source <(curl -fsSL "$REPO_URL/color-generator.sh")
source <(curl -fsSL "$REPO_URL/error-reporter.sh")

# Lade die Liste unterstützter Betriebssysteme direkt
OS_LIST=$(curl -fsSL "$REPO_URL/supported_os_list.json")

if [ -z "$OS_LIST" ]; then
    log_error_report "Failed to download the supported OS list." "UNKNOWN" "UNKNOWN" "UNKNOWN" "UNKNOWN" "System Check" "Download OS list"
    exit 1
fi

# Systeminformationen abrufen
OS_NAME=$(lsb_release -si)
OS_VERSION=$(lsb_release -sr)
ARCHITECTURE=$(uname -m)
KERNEL_VERSION=$(uname -r)

# Zeige Systeminformationen an
log_info "Operating System: $OS_NAME"
log_info "Version: $OS_VERSION"
log_info "Architecture: $ARCHITECTURE"
log_info "Kernel Version: $KERNEL_VERSION"

# Systemkompatibilität überprüfen
SUPPORTED=false
MATCHED_SCRIPT=""


while IFS= read -r line; do
    os_name=$(echo "$line" | jq -r '.os')
    os_version=$(echo "$line" | jq -r '.version')
    arch=$(echo "$line" | jq -r '.architecture')
    script_name=$(echo "$line" | jq -r '.script')

    if [[ "$os_name" == "$OS_NAME" && "$os_version" == "$OS_VERSION" && "$arch" == "$ARCHITECTURE" ]]; then
        SUPPORTED=true
        MATCHED_SCRIPT="$script_name"
        break
    fi
done <<< "$(echo "$OS_LIST" | jq -c '.[]')"

# Falls nicht unterstützt, Fehlerbericht ausgeben
if [ "$SUPPORTED" == "false" ]; then
    log_error_report "Your system ($OS_NAME $OS_VERSION) is not supported." "$OS_NAME" "$OS_VERSION" "$ARCHITECTURE" "$KERNEL_VERSION" "System Check" "Check system compatibility"
    exit 1
else
    log_success "The system is compatible! Running the installation script..."
fi

# Falls ein passendes Installationsskript existiert, direkt ausführen
if [ -n "$MATCHED_SCRIPT" ]; then
    SCRIPT_URL="$REPO_URL/install_scripts/$MATCHED_SCRIPT"
    echo -e "\e[34m[INFO]\e[0m Running installation script from: $SCRIPT_URL"
    
    # Direkt ausführen (ohne Zwischenspeicherung)
    bash <(curl -fsSL "$SCRIPT_URL")
else
    log_error_report "No installation script found for $OS_NAME $OS_VERSION." "$OS_NAME" "$OS_VERSION" "$ARCHITECTURE" "$KERNEL_VERSION" "Script Find" "Find matching script"
    exit 1
fi
