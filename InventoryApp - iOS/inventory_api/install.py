from __future__ import annotations
import json
import sys
from pathlib import Path
import pymysql

# Gracefully handle install failure
def fail(msg: str, code: int = 1) -> None:
    print(f"ERROR: {msg}")
    raise SystemExit(code)

# Load the newly created auth.json file
def load_auth(project_dir: Path) -> dict:
    auth_path = project_dir / "auth" / "auth.json"
    if not auth_path.exists():
        fail(f"auth.json not found at {auth_path}")

    try:
        auth = json.loads(auth_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as e:
        fail(f"Failed to parse auth.json: {e}")

    for key in ("host", "user", "password", "database"):
        if not auth.get(key):
            fail(f"auth.json missing required field: {key}")

    return auth

# Test database connection
def connect_db(auth: dict) -> pymysql.connections.Connection:
    try:
        return pymysql.connect(
            host=auth["host"],
            user=auth["user"],
            password=auth["password"],
            database=auth["database"],
            autocommit=True,
            charset="utf8mb4",
        )
    except Exception as e:
        fail(f"Unable to connect to MariaDB: {e}")

# Create the tables specific to our project's schema
def ensure_schema(conn: pymysql.connections.Connection) -> None:
    schema_statements = [
        """
        CREATE TABLE IF NOT EXISTS user_types (
            id          TINYINT UNSIGNED NOT NULL,
            name        VARCHAR(50) NOT NULL,
            description VARCHAR(255) NULL,
            PRIMARY KEY (id),
            UNIQUE KEY uq_user_types_name (name)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        """,
        """
        CREATE TABLE IF NOT EXISTS users (
            id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
            username      VARCHAR(50) NOT NULL,
            password_hash VARCHAR(255) NOT NULL,
            user_type_id  TINYINT UNSIGNED NOT NULL,
            last_login_at DATETIME NULL,
            created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (id),
            UNIQUE KEY uq_users_username (username),
            KEY idx_users_user_type_id (user_type_id),
            CONSTRAINT fk_users_user_type
                FOREIGN KEY (user_type_id) REFERENCES user_types(id)
                ON UPDATE RESTRICT ON DELETE RESTRICT
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        """,
        """
        CREATE TABLE IF NOT EXISTS inventory_items (
            id           INT UNSIGNED NOT NULL AUTO_INCREMENT,
            uuid         CHAR(36) NOT NULL,
            name         VARCHAR(100) NOT NULL,
            quantity     INT NOT NULL,
            max_quantity INT NOT NULL,
            location     VARCHAR(100) NOT NULL,
            symbol_name  VARCHAR(100) NOT NULL DEFAULT 'shippingbox',
            created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
            updated_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (id),
            UNIQUE KEY uq_inventory_items_uuid (uuid)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        """,
        """
        CREATE TABLE IF NOT EXISTS inventory_item_audit (
            id                BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
            inventory_item_id INT UNSIGNED NOT NULL,
            user_id           INT UNSIGNED NOT NULL,
            user_type_id      TINYINT UNSIGNED NOT NULL,
            change_amount     INT NOT NULL,
            old_quantity      INT NOT NULL,
            new_quantity      INT NOT NULL,
            occurred_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
            note              VARCHAR(255) NULL,
            PRIMARY KEY (id),
            KEY idx_audit_item_id (inventory_item_id),
            KEY idx_audit_user_id (user_id),
            KEY idx_audit_user_type_id (user_type_id),
            KEY idx_audit_occurred_at (occurred_at),
            CONSTRAINT fk_audit_item
                FOREIGN KEY (inventory_item_id) REFERENCES inventory_items(id)
                ON UPDATE RESTRICT ON DELETE RESTRICT,
            CONSTRAINT fk_audit_user
                FOREIGN KEY (user_id) REFERENCES users(id)
                ON UPDATE RESTRICT ON DELETE RESTRICT,
            CONSTRAINT fk_audit_user_type
                FOREIGN KEY (user_type_id) REFERENCES user_types(id)
                ON UPDATE RESTRICT ON DELETE RESTRICT
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        """,
    ]

    # Seed the 
    seed_user_types = """
    INSERT IGNORE INTO user_types (id, name, description) VALUES
        (1, 'Employee',   'Standard warehouse employee'),
        (2, 'Manager', 'Warehouse manager'),
        (3, 'Admin',    'Full administrative privileges');
    """

    with conn.cursor() as cur:
        for stmt in schema_statements:
            cur.execute(stmt)
        cur.execute(seed_user_types)


def main() -> int:
    project_dir = Path(__file__).resolve().parent
    auth = load_auth(project_dir)

    conn = None
    try:
        conn = connect_db(auth)
        ensure_schema(conn)
        print("[OK] Connected to MariaDB and ensured schema exists.")
        return 0
    finally:
        if conn:
            conn.close()


if __name__ == "__main__":
    sys.exit(main())