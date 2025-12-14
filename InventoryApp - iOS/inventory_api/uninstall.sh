#!/bin/bash

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
VENV_DIR="$PROJECT_DIR/venv"
REQ_FILE="$PROJECT_DIR/requirements.txt"
AUTH_DIR="$PROJECT_DIR/auth"
AUTH_FILE="$AUTH_DIR/auth.json"

SERVICE_NAME="inventory_api.service"
SERVICE_PATH="/etc/systemd/system/$SERVICE_NAME"
SERVICE_USER="$SUDO_USER"

# Protect the root directory from accidental deletion
if [[ "$PROJECT_DIR" == "/" ]]; then
    echo "ERROR: PROJECT_DIR resolved to root (/). Aborting for safety."
    exit 1
fi

echo "=== Inventory API Uninstaller ==="

# Check if we are running this script with sudo privilages
if [ -z "$SERVICE_USER" ]; then
    echo "ERROR: This script must be run with sudo (not as root directly)."
    exit 1
fi

# Remove the venv
if [ -d "$VENV_DIR" ]; then
    echo "[+] Removing virtual environment..."
    rm -rf "$VENV_DIR"
else
    echo "[=] venv not found. Skipping removal."
fi

# Remove the __pycache__ directories
echo "[+] Cleaning Python cache files..."
find "$PROJECT_DIR" -type d -name "__pycache__" -exec rm -rf {} +

# Remove the requirements.txt file
if [ -f "$REQ_FILE" ]; then
    echo "[+] Removing requirements.txt"
    rm -f "$REQ_FILE"
else
    echo "[=] No requirements.txt found. Skipping."
fi

# Remove the auth.json file
if [ -f "$AUTH_FILE" ]; then
    echo "[+] Removing auth.json"
    rm -f "$AUTH_FILE"
else
    echo "[=] No auth.json found. Skipping."
fi

echo "[+] Removing systemd service ($SERVICE_NAME)"

# Stop the service
systemctl stop "$SERVICE_NAME" 2>/dev/null || true

# Disable on boot
systemctl disable "$SERVICE_NAME" 2>/dev/null || true

# Remove the unit file if it exists
if [ -f "$SERVICE_PATH" ]; then
    echo "[+] Deleting $SERVICE_PATH..."
    rm -f "$SERVICE_PATH"
else
    echo "[=] Service file not found. Skipping."
fi

# Reload systemd so it forgets the unit
systemctl daemon-reload

echo "======================================="
echo " Uninstall complete!"
echo "This uninstaller does NOT drop your MariaDB database or tables."
echo "If you want to permanently remove the Inventory API database,"
echo "run the following commands manually:"
echo
echo "  mariadb -u <db_user> -p -h <db_host>"
echo "  USE <database_name>;"
echo "  DROP DATABASE <database_name>;"
echo
echo " WARNING: This action is irreversible and will permanently"
echo "   delete ALL inventory data."
echo
echo " You can now remove the project directory to complete the uninstallation."
echo "======================================="