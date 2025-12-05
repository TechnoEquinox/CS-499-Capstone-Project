#!/bin/bash

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
VENV_DIR="$PROJECT_DIR/venv"
REQ_FILE="$PROJECT_DIR/requirements.txt"

# Protect the root directory from accidental deletion
if [[ "$PROJECT_DIR" == "/" ]]; then
    echo "ERROR: PROJECT_DIR resolved to root (/). Aborting for safety."
    exit 1
fi

echo "=== Inventory API Uninstaller ==="

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

echo "======================================="
echo " Uninstall complete!"
echo "======================================="