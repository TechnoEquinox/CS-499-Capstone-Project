from flask import Blueprint, request, jsonify
from argon2 import PasswordHasher
from argon2.exceptions import VerifyMismatchError
from flask_jwt_extended import create_access_token, jwt_required, get_jwt_identity, get_jwt
from db import get_db_connection

auth_bp = Blueprint("auth", __name__, url_prefix="/auth")

ph = PasswordHasher()

DEFAULT_USER_TYPE_ID = 1 # Employee user type

# Input validation checks on the username
def _is_valid_username(username: str) -> bool:
    if not username:
        return False
    if len(username) < 3 or len(username) > 30:
        return False
    return all(c.isalnum() or c in "_-" for c in username)

# New user can register for an account on /register
@auth_bp.post("/register")
def register():
    data = request.get_json(silent=True) or {}
    username = (data.get("username") or "").strip()
    client_password_hash = (data.get("client_password_hash") or "").strip()

    if not _is_valid_username(username):
        return jsonify({"error": "Invalid username"}), 400
    
    # Expect a SHA-256 string from client
    if len(client_password_hash) != 64:
        return jsonify({"error": "Invalid password"}), 400
    
    password_hash = ph.hash(client_password_hash)

    conn = get_db_connection()
    try:
        with conn.cursor() as cur:
            # Enforce unique username
            cur.execute("SELECT id FROM users WHERE username=%s", (username,))
            if cur.fetchone():
                return jsonify({"error": "Username already exists"}), 409
            
            # Execute the command on the db
            cur.execute(
                """
                INSERT INTO users (username, password_hash, user_type_id)
                VALUES (%s, %s, %s)
                """,
                (username, password_hash, DEFAULT_USER_TYPE_ID),
            )
            conn.commit()

            user_id = cur.lastrowid
        
        access_token = create_access_token(
            identity= str(user_id),
            additional_claims= {
                "username": username,
                "user_type_id": DEFAULT_USER_TYPE_ID,
            },
        )
        return jsonify({"access_token": access_token}), 201
    finally:
        conn.close()

# Existing user can login from /login
@auth_bp.post("/login")
def login():
    data = request.get_json(silent=True) or {}
    username = (data.get("username") or "").strip()
    client_password_hash = (data.get("client_password_hash") or "").strip()

    if not username or len(client_password_hash) != 64:
        return jsonify({"error": "Invalid login credentials"}), 400
    
    conn = get_db_connection()
    try: 
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT id, username, password_hash, user_type_id
                FROM users
                WHERE username=%s
                """,
                (username,),
            )
            row = cur.fetchone()

            if not row:
                return jsonify({"error": "Invalid credentials"}), 401
            
            user_id = row["id"]
            db_username = row["username"]
            stored_hash = row["password_hash"]
            user_type_id = row["user_type_id"]

            # Verify the password hash in the login request matches the password hash stored in our db
            try:
                ph.verify(stored_hash, client_password_hash)
            except VerifyMismatchError:
                return jsonify({"error": "Invalid credentials. Password is incorrect"}), 401

            cur.execute("UPDATE users SET last_login_at=NOW() WHERE id=%s", (user_id,))
            conn.commit()
        
        access_token = create_access_token(
            identity = str(user_id),
            additional_claims = {
                "username": db_username,
                "user_type_id": user_type_id,
            },
        )

        return jsonify({"access_token": access_token}), 200

    finally:
        conn.close()
    
@auth_bp.get("/me")
@jwt_required()
def me():
    user_id = int(get_jwt_identity())
    claims = get_jwt()
    return jsonify({
        "user_id": user_id,
        "username": claims.get("username"),
        "user_type_id": claims.get("user_type_id"),
    }), 200