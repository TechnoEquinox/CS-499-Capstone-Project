#!/bin/bash

set -e # Stop on error

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
VENV_DIR="$PROJECT_DIR/venv"
REQUIREMENTS_FILE="$PROJECT_DIR/requirements.txt"
AUTH_DIR="$PROJECT_DIR/auth"
AUTH_FILE="$AUTH_DIR/auth.json"

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

echo "======================================="
echo " Installation complete!"
echo " To run the server: source venv/bin/activate && python app.py"
echo "======================================="