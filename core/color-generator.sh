#!/bin/bash

# Farben definieren
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
RESET='\033[0m'  # Reset auf Standardfarbe

# Funktion für erfolgreiche Meldungen
log_success() {
    echo -e "${GREEN}[SUCCESS]${RESET} $1"
}

# Funktion für Informationsmeldungen
log_info() {
    echo -e "${BLUE}[INFO]${RESET} $1"
}

# Funktion für Fehlermeldungen
log_error() {
    echo -e "${RED}[ERROR]${RESET} $1"
}

# Funktion für Warnmeldungen
log_warning() {
    echo -e "${YELLOW}[WARNING]${RESET} $1"
}
