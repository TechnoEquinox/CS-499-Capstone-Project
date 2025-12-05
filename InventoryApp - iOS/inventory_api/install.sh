#!/bin/bash

set -e # Stop on error

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
VENV_DIR="$PROJECT_DIR/venv"
REQUIREMENTS_FILE="$PROJECT_DIR/requirements.txt"

echo "=== Inventory API Installer ==="

# Check for and create the venv
if [ ! -d "$VENV_DIR" ]; then
    echo "[+] Creating virtual environment..."
    python3 -m venv "$VENV_DIR"
else
    echo "[=] venv already exists. Skipping creation."
fi

# Activate the venv
echo "[+] Activating virtual environment..."
source "$VENV_DIR/bin/activate"

# Install the required dependencies
echo "[+] Checking required Python packages..."
# If no requirements file exists, create a minimal one
if [ ! -f "$REQUIREMENTS_FILE" ]; then
    echo "[!] requirements.txt not found. Creating a default one..."
    cat <<EOF > "$REQUIREMENTS_FILE"
Flask
pymysql
python-dotenv
EOF
fi

echo "[+] Installing / updating packages..."
pip install --upgrade pip
pip install -r "$REQUIREMENTS_FILE"

echo "======================================="
echo " Installation complete!"
echo " To run the server: source venv/bin/activate && python app.py"
echo "======================================="