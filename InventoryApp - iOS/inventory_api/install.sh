#!/bin/bash

set -e # Stop on error

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
VENV_DIR="$PROJECT_DIR/venv"
REQUIREMENTS_FILE="$PROJECT_DIR/requirements.txt"
AUTH_DIR="$PROJECT_DIR/auth"
AUTH_FILE="$AUTH_DIR/auth.json"

SERVICE_NAME="inventory_api.service"
SERVICE_PATH="/etc/systemd/system/$SERVICE_NAME"
SERVICE_USER="$SUDO_USER"
SERVICE_GROUP="$SUDO_USER"

echo "=== Inventory API Installer ==="

# Check if we are running this script with sudo privilages
if [ -z "$SERVICE_USER" ]; then
    echo "ERROR: This script must be run with sudo (not as root directly)."
    exit 1
fi

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
argon2-cffi
Flask-JWT-Extended
EOF
fi

echo "[+] Installing / updating packages..."
pip install --upgrade pip
pip install -r "$REQUIREMENTS_FILE"

echo "[+] Checking for auth directory..."
if [ ! -d "$AUTH_DIR" ]; then
    echo "[!] $AUTH_DIR not found. Creating $AUTH_DIR..."
    mkdir -p "$AUTH_DIR"
else
    echo "[=] auth directory already exists."
fi

# Ensure auth.json exists
echo "[+] Checking for auth.json..."
if [ ! -f "$AUTH_FILE" ]; then
    echo "[!] auth.json not found. Creating $AUTH_FILE..."
    echo "Please configure the database connection details:"

    read -r -p "Host: " DB_HOST
    read -r -p "DB User: " DB_USER
    read -r -s -p "DB Password: " DB_PASSWORD
    echo
    read -r -p "Database Name: " DB_NAME
    
    echo "[+] Creating the JWT Secret Key..."
    JWT_SECRET_KEY="$(python3 - <<'PY'
import secrets
print(secrets.token_hex(64))
PY
)"
    
    cat <<EOF > "$AUTH_FILE"
{
    "host": "$DB_HOST",
    "user": "$DB_USER",
    "password": "$DB_PASSWORD",
    "database": "$DB_NAME",
    "jwt_secret_key": "$JWT_SECRET_KEY"
}
EOF

    echo "[+] Created $AUTH_FILE"
else
    echo "[=] auth.json already exists. Skipping creation."
fi

echo "[+] Checking MariaDB client..."
if ! command -v mariadb >/dev/null 2>&1 && ! command -v mysql >/dev/null 2>&1; then
    echo "[!] MariaDB/MySQL client not found. Perform the following and rerun:"
    echo "    sudo apt-get update && sudo apt-get install -y mariadb-client.  "
    exit 1
fi

echo "[+] Setting up the MariaDB schema using auth.json..."
#"$VENV_DIR/bin/python3" "$PROJECT_DIR/install.py"

echo "[+] Installing systemd service ($SERVICE_NAME)..."
cat <<EOF > "$SERVICE_PATH"
[Unit]
Description=Inventory API (Flask), created by Connor Bailey for CS-499 Capstone Project.
After=network.target

[Service]
Type=simple

# Run as invoking user
User=$SERVICE_USER
Group=$SERVICE_GROUP

# Project directory
WorkingDirectory=$PROJECT_DIR

# Virtual environment Python
ExecStart=$PROJECT_DIR/venv/bin/python3 $PROJECT_DIR/app.py

# Restart on failure
Restart=always
RestartSec=5

# Logging
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

echo "[+] Reloading systemd..."
systemctl daemon-reload

echo "[+] Enabling service on boot..."
systemctl enable "$SERVICE_NAME"

echo "[+] Restarting service now..."
systemctl restart "$SERVICE_NAME"

echo "[+] Service status:"
systemctl --no-pager status "$SERVICE_NAME"

echo "======================================="
echo " Installation complete!"
echo " The service should now be running on port 5000."
echo "======================================="