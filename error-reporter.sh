#!/bin/bash

# Funktion zum Erstellen eines Fehlerberichts
log_error_report() {
    local message="$1"
    local os_name="$2"
    local os_version="$3"
    local architecture="$4"
    local kernel_version="$5"
    local check_type="$6"
    local action="$7"

    echo -e "${RED}[ERROR REPORT]${RESET} $message"
    echo "System Information:"
    echo "  OS: $os_name $os_version"
    echo "  Architecture: $architecture"
    echo "  Kernel: $kernel_version"
    echo "  Check: $check_type"
    echo "  Action: $action"
    echo "Please report this issue to the developer on GitHub or Discord, and provide the log above."

    # Optional: Hier kannst du den Fehlerbericht auch an ein API oder eine Log-Datei senden.
}
