import pymysql
import json
import sys
from pathlib import Path

AUTH_PATH = Path("auth/auth.json")

# Load the MariaDB credentials from auth.json
try:
    with open(AUTH_PATH, "r") as f:
        auth = json.load(f)
    JWT_SECRET_KEY = auth.get("jwt_secret_key")
    if not JWT_SECRET_KEY:
        print("ERROR: jwt_secret_key missing from auth.json")
        sys.exit(1)
except FileNotFoundError:
    print(f"ERROR: auth.json not found at {AUTH_PATH}")
    sys.exit(1)
except json.JSONDecodeError as e:
    print(f"ERROR: Failed to parse auth.json: {e}")
    sys.exit(1)

DB_CONFIG = {
    "host": auth.get("host", "localhost"),
    "user": auth["user"],
    "password": auth["password"],
    "database": auth["database"],
    "cursorclass": pymysql.cursors.DictCursor,
    "charset": "utf8mb4"
}

def get_db_connection():
    """
    Returns a new MariaDB connection.
    Caller is responsible for closing it.
    """
    try:
        return pymysql.connect(**DB_CONFIG)
    except pymysql.MySQLError as err:
        print("Database connection failed: %s", err)
        abort(503, description="Database connection failed.")