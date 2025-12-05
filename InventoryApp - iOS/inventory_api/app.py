from flask import Flask, jsonify, request
import json
import pymysql
from pathlib import Path
import sys
import uuid

app = Flask(__name__)

AUTH_PATH = "auth/auth.json"

# Load all of the authentication variables from auth.json
try:
    with open(AUTH_PATH, "r") as f:
        auth = json.load(f)
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
    # TODO: Add error handling
    return pymysql.connect(**DB_CONFIG)


@app.route("/get-all-items", methods=["GET"])
def get_items():
    # Return all inventory items in a JSON format that matches our Swift struct
    conn = get_db_connection()
    
    try:
        with conn.cursor() as cursor:
            # We use uuid (the Swift id), not the numeric primary key
            sql = """
                SELECT
                    uuid,
                    name,
                    quantity,
                    max_quantity,
                    location,
                    symbol_name
                FROM inventory_items
                ORDER BY name ASC;
            """
            cursor.execute(sql)
            rows = cursor.fetchall()

            # Map DB column names -> JSON keys expected by the iOS app
            items = []
            for row in rows:
                items.append({
                    "id": row["uuid"],  # Swift UUID as string
                    "name": row["name"],
                    "quantity": row["quantity"],
                    "maxQuantity": row["max_quantity"],
                    "location": row["location"],
                    "symbolName": row["symbol_name"],
                })

        return jsonify(items), 200
    # TODO: Add better error handling
    finally:
        conn.close()

@app.route("/add-item", methods=["POST"])
def add_item():
    # Place newly created inventory item into the database
    data = request.get_json(silent=True)

    if not data:
        return jsonify({
            "status": "error",
            "message": "Request body must be valid JSON."
        }), 400
    
    try:
        name = str(data["name"]).strip()
        location = str(data["location"]).strip()
        quantity = int(data["quantity"])
        max_quantity = int(data["maxQuantity"])
        symbol_name = str(data.get("symbolName", "shippingbox")).strip() or "shippingbox"
    except (KeyError, TypeError, ValueError) as err:
        return jsonify({
            "status": "error",
            "message": f"Missing or invalid fields: {err}"
        }), 400
    
    # Input validation to ensure only sanitized data enters the database
    if not name:
        return jsonify({"status": "error", "message": "name cannot be empty."}), 400
    if not location:
        return jsonify({"status": "error", "message": "location cannot be empty."}), 400
    if quantity < 0:
        return jsonify({"status": "error", "message": "quantity cannot be negative."}), 400
    if max_quantity <= 0:
        return jsonify({"status": "error", "message": "maxQuantity must be greater than 0."}), 400
    if quantity > max_quantity:
        return jsonify({"status": "error", "message": "quantity cannot be greater than maxQuantity."}), 400
    
    item_uuid = str(uuid.uuid4())

    # Database operation
    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            sql = """
                INSERT INTO inventory_items
                    (uuid, name, quantity, max_quantity, location, symbol_name)
                VALUES (%s, %s, %s, %s, %s, %s)
            """
            cursor.execute(sql, (
                item_uuid,
                name,
                quantity,
                max_quantity,
                location,
                symbol_name
            ))
        conn.commit()
    finally:
        conn.close()
    
    # NOTE: We probably don't have to return the whole item again
    return jsonify({
        "status": "ok",
        "item": {
            "id": item_uuid,
            "name": name,
            "quantity": quantity,
            "maxQuantity": max_quantity,
            "location": location,
            "symbolName": symbol_name
        }
    }), 201

@app.route("/delete-item", methods=["POST"])
def delete_item():
    # Delete an inventory item by UUID
    data = request.get_json(silent=True)

    # UUID validation
    if not data:
        return jsonify({
            "status" : "error",
            "message": "Request body must be valid JSON." 
        }), 400

    item_id = data.get("id")
    if not item_id:
        return jsonify({
            "status": "error",
            "message": "Field 'id' (UUID) is required."
        }), 400
    
    try:
        _ = uuid.UUID(item_id)
    except ValueError:
        return jsonify({
            "status": "error",
            "message": "Field 'id' must be a valid UUID string."
        }), 400
    
    # Database operation
    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            sql = "DELETE FROM inventory_items WHERE uuid = %s"
            rows_affected = cursor.execute(sql, (item_id,))
        conn.commit()
    finally:
        conn.close()
    
    if rows_affected == 0:
        return jsonify({
            "status": "error",
            "message": f"No item found with id {item_id}."
        }), 404

    return jsonify({
        "status": "ok",
        "message": "Item deleted successfully.",
        "id": item_id
    }), 200

@app.route("/modify-item", methods=["POST"])
def modify_item():
    # Modify an existing inventory item
    # Every field other than id is optional, only provided fields will be updated
    data = request.get_json(silent=True)

    if not data:
        return jsonify({
            "status": "error",
            "message": "Request body must be valid JSON."
        }), 400

    item_id = data.get("id")
    if not item_id:
        return jsonify({
            "status": "error",
            "message": "Field 'id' (UUID) is required."
        }), 400
    
    # Database operation
    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            # Fetch current item state
            select_sql = """
                SELECT
                    uuid,
                    name,
                    quantity,
                    max_quantity,
                    location,
                    symbol_name
                FROM inventory_items
                WHERE uuid = %s
            """
            cursor.execute(select_sql, (item_id,))
            row = cursor.fetchone()

            if not row:
                return jsonify({
                    "status": "error",
                    "message": f"No item found with id {item_id}."
                }), 404

            # Merge the existing values with the values provided
            try:
                name = str(data.get("name", row["name"])).strip()
                location = str(data.get("location", row["location"])).strip()
                quantity = int(data.get("quantity", row["quantity"]))
                max_quantity = int(data.get("maxQuantity", row["max_quantity"]))
                symbol_name = str(data.get("symbolName", row["symbol_name"])).strip()
            except (TypeError, ValueError) as err:
                return jsonify({
                    "status": "error",
                    "message": f"Invalid field types: {err}"
                }), 400
            
            # Input Validation
            if not name:
                return jsonify({"status": "error", "message": "name cannot be empty."}), 400
            if not location:
                return jsonify({"status": "error", "message": "location cannot be empty."}), 400
            if quantity < 0:
                return jsonify({"status": "error", "message": "quantity cannot be negative."}), 400
            if max_quantity <= 0:
                return jsonify({"status": "error", "message": "maxQuantity must be greater than 0."}), 400
            if quantity > max_quantity:
                return jsonify({"status": "error", "message": "quantity cannot be greater than maxQuantity."}), 400
            
            # Perform the update
            update_sql = """
                UPDATE inventory_items
                SET name = %s,
                    quantity = %s,
                    max_quantity = %s,
                    location = %s,
                    symbol_name = %s
                WHERE uuid = %s
            """
            cursor.execute(update_sql, (
                name,
                quantity,
                max_quantity,
                location,
                symbol_name,
                item_id
            ))
        conn.commit()
    finally:
        conn.close()

    # NOTE: We probably don't have to return the whole item again
    return jsonify({
        "status": "ok",
        "item": {
            "id": item_id,
            "name": name,
            "quantity": quantity,
            "maxQuantity": max_quantity,
            "location": location,
            "symbolName": symbol_name
        }
    }), 200

@app.route("/ping", methods=["GET"])
def health_check():
    return jsonify({
        "status": "ok",
        "message": "pong"
    }), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
