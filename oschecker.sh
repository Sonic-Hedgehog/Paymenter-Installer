#!/bin/bash

# Standard-Branch (falls kein Argument übergeben wird)
installer_branch="main"

# Prüfen, ob ein Argument für den Branch übergeben wurde
if [ ! -z "$1" ]; then
    installer_branch="$1"
    echo -e "${BLUE}[INFO]${RESET} Using branch: $installer_branch"
else
    echo -e "${BLUE}[INFO]${RESET} No branch specified, using default branch: $installer_branch"
fi

# Überprüfe, ob curl installiert ist
if ! command -v curl &> /dev/null; then
    echo -e "${RED}[ERROR]${RESET} curl is not installed."

    # Frage den Benutzer, ob curl installiert werden soll
    read -p "Would you like to install curl? (y/n): " answer

    if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
        # Installiere curl je nach Distribution
        echo -e "${BLUE}[INFO]${RESET} Installing curl..."

        if [ -f /etc/debian_version ]; then
            # Debian/Ubuntu-basierte Systeme
            sudo apt-get update
            sudo apt-get install -y curl
        elif [ -f /etc/redhat-release ]; then
            # RedHat/CentOS-basierte Systeme
            sudo yum install -y curl
        elif command -v dnf &> /dev/null; then
            # Fedora-basierte Systeme
            sudo dnf install -y curl
        else
            echo -e "${RED}[ERROR]${RESET} Unsupported system for automatic curl installation."
            exit 1
        fi

        # Überprüfe, ob curl nun erfolgreich installiert wurde
        if command -v curl &> /dev/null; then
            echo -e "${GREEN}[SUCCESS]${RESET} curl has been successfully installed!"
        else
            echo -e "${RED}[ERROR]${RESET} Failed to install curl. Please install it manually and try again."
            exit 1
        fi
    else
        # Wenn der Benutzer "nein" sagt, beende das Skript mit einer Fehlermeldung
        echo -e "${RED}[ERROR]${RESET} curl is required to proceed. The script cannot continue without curl."
        exit 1
    fi
fi

# GitHub repository URL für die Skripte
REPO_URL="https://raw.githubusercontent.com/Sonic-Hedgehog/paymenter-installer/$installer_branch"

# Lade Farbgenerator und Fehlerbericht-Skript
curl -fsSL "$REPO_URL/color-generator.sh" -o color-generator.sh
curl -fsSL "$REPO_URL/error-reporter.sh" -o error-reporter.sh

# Prüfen, ob die Skripte erfolgreich heruntergeladen wurden
if [ ! -f "color-generator.sh" ] || [ ! -f "error-reporter.sh" ]; then
    echo -e "${RED}[ERROR]${RESET} Failed to download the required scripts from GitHub."
    exit 1
fi

# Skripte ausführen
chmod +x color-generator.sh error-reporter.sh
source ./color-generator.sh
source ./error-reporter.sh

# Lade unterstützte Systeme (JSON-Datei) herunter und überprüfe die Kompatibilität
curl -fsSL "$REPO_URL/supported_os_list.json" -o supported_os_list.json
if [ ! -f "supported_os_list.json" ]; then
    echo -e "${RED}[ERROR]${RESET} Failed to download the supported OS list."
    exit 1
fi

# Hole Systeminformationen
OS_NAME=$(lsb_release -si)
OS_VERSION=$(lsb_release -sr)
ARCHITECTURE=$(uname -m)
KERNEL_VERSION=$(uname -r)

# Zeige Systeminformationen
log_info "Operating System: $OS_NAME"
log_info "Version: $OS_VERSION"
log_info "Architecture: $ARCHITECTURE"
log_info "Kernel Version: $KERNEL_VERSION"

# Überprüfe, ob das System unterstützt wird
SUPPORTED=false
MATCHED_SCRIPT=""

# Prüfe auf kompatible Systeme aus der JSON-Datei
while read -r line; do
    if echo "$line" | grep -q "\"os\": \"$OS_NAME\""; then
        if echo "$line" | grep -q "\"version\": \"$OS_VERSION\""; then
            SUPPORTED=true
            MATCHED_SCRIPT=$(echo "$line" | grep -oP '"script": "\K([^"]+)')
            break
        fi
    fi
done < supported_os_list.json

# Wenn nicht unterstützt, Fehler melden
if [ "$SUPPORTED" == "false" ]; then
    log_error_report "Your system ($OS_NAME $OS_VERSION) is not supported." "$OS_NAME" "$OS_VERSION" "$ARCHITECTURE" "$KERNEL_VERSION" "System Check" "Check system compatibility"
    exit 1
else
    log_success "The system is compatible! Downloading the installation script..."
fi

# Installationsskript direkt von GitHub ausführen
if [ -n "$MATCHED_SCRIPT" ]; then
    SCRIPT_URL="$REPO_URL/install_scripts/$MATCHED_SCRIPT"
    echo -e "${BLUE}[INFO]${RESET} Running installation script from: $SCRIPT_URL"
    
    # Direktes Ausführen des heruntergeladenen Skripts ohne Zwischenspeicherung
    curl -fsSL "$SCRIPT_URL" | bash
else
    log_error_report "No installation script found for $OS_NAME $OS_VERSION." "$OS_NAME" "$OS_VERSION" "$ARCHITECTURE" "$KERNEL_VERSION" "Script Find" "Find matching script"
    exit 1
fi
