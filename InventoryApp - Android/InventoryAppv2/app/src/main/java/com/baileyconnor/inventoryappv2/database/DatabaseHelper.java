package com.baileyconnor.inventoryappv2.database;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

import androidx.annotation.Nullable;

import com.baileyconnor.inventoryappv2.model.Item;

import java.util.ArrayList;
import java.util.List;


public class DatabaseHelper extends SQLiteOpenHelper {
    private static final String DB_NAME = "inventory_app.db";
    private static final int DB_VERSION = 4;

    // users table
    // T = Table, C = Column
    public static final String T_USERS = "users";
    public static final String C_USERNAME = "username";
    public static final String C_PASSWORD = "password";

    // items table
    // T = Table, C = Column
    public static final String T_ITEMS = "items";
    public static final String C_ID = "id";
    public static final String C_NAME = "name";
    public static final String C_QTY = "quantity";
    public static final String C_LOCATION = "location";
    public static final String C_UPDATED_AT = "updated_at";

    // Constructor
    public DatabaseHelper(@Nullable Context context) {
        super(context, DB_NAME, null, DB_VERSION);
    }

    @Override
    public void onCreate(SQLiteDatabase db) {
        // Create the user login table
        db.execSQL("CREATE TABLE " + T_USERS + " (" +
                C_USERNAME + " TEXT PRIMARY KEY, " +
                C_PASSWORD + " TEXT NOT NULL)");

        // Create the item inventory table
        db.execSQL("CREATE TABLE " + T_ITEMS + " (" +
                C_ID + " INTEGER PRIMARY KEY AUTOINCREMENT, " +
                C_NAME + " TEXT NOT NULL, " +
                C_QTY + " INTEGER NOT NULL DEFAULT 0, " +
                C_LOCATION + " TEXT, " +
                C_UPDATED_AT + " INTEGER NOT NULL)");
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        // Drop all existing tables to start fresh
        db.execSQL("DROP TABLE IF EXISTS " + T_ITEMS);
        db.execSQL("DROP TABLE IF EXISTS " + T_USERS);
        // Create new tables
        onCreate(db);
    }

    // --- --- Helper Functions --- --- \\

    // Returns true if a user was created, false if the username exists or
    // an error occurs when inserting the value into the table
    public boolean createUser(String username, String password) {
        SQLiteDatabase db = getWritableDatabase();
        ContentValues cv = new ContentValues();
        cv.put(C_USERNAME, username.trim());
        cv.put(C_PASSWORD, password);

        long rowID = -1;
        try {
            rowID = db.insertOrThrow(T_USERS, null, cv);
        } catch (Exception error) {
            System.out.println("ERROR: An error occurred when inserting a new user into the database: " + error);
        }

        // Return true if the rowID has been updated, false if it hasn't been updated
        return rowID != -1;
    }

    // Returns true if the username and password combination exist in the database
    public boolean validateLogin(String username, String password) {
        SQLiteDatabase db = getReadableDatabase();
        String[] cols = { C_USERNAME };
        String sel = C_USERNAME + "=? AND " + C_PASSWORD + "=?";

        // Args to validate
        String[] args = { username.trim(), password };

        try (Cursor c = db.query(T_USERS, cols, sel, args, null, null, null)) {
            return c.moveToFirst();
        }
    }

    // --- CRUD Functions for Items Table --- \\

    // Insert an item into the database
    public long insertItem(Item item) {
        SQLiteDatabase db = getWritableDatabase();
        ContentValues cv = new ContentValues();
        cv.put(C_NAME, item.getName());
        cv.put(C_QTY, item.getQuantity());
        cv.put(C_LOCATION, item.getLocation());
        cv.put(C_UPDATED_AT, System.currentTimeMillis());
        return db.insert(T_ITEMS, null, cv);
    }

    // Update an item that already exists in the database
    public int updateItem(Item item) {
        SQLiteDatabase db = getWritableDatabase();
        ContentValues cv = new ContentValues();
        cv.put(C_NAME, item.getName());
        cv.put(C_QTY, item.getQuantity());
        cv.put(C_LOCATION, item.getLocation());
        cv.put(C_UPDATED_AT, System.currentTimeMillis());
        return db.update(T_ITEMS, cv, C_ID + "=?", new String[] { String.valueOf(item.getId()) });
    }

    // Delete an item in the database
    public int deleteItem(long id) {
        SQLiteDatabase db = getWritableDatabase();
        return db.delete(T_ITEMS, C_ID + "=?", new String[] { String.valueOf(id) });
    }

    // Get a single item by the item's primary key
    public Item getItemById(long id) {
        SQLiteDatabase db = getReadableDatabase();
        try (Cursor c = db.query(
                T_ITEMS,
                null,
                C_ID + "=?",
                new String[] { String.valueOf(id) },
                null, null, null
        )) {
            if (c.moveToFirst()) {
                return new Item (
                        c.getLong(c.getColumnIndexOrThrow(C_ID)),
                        c.getString(c.getColumnIndexOrThrow(C_NAME)),
                        c.getInt(c.getColumnIndexOrThrow(C_QTY)),
                        c.getString(c.getColumnIndexOrThrow(C_LOCATION))
                );
            }
        }
        return null;
    }

    // Get all of the items in the database
    public List<Item> getAllItems() {
        SQLiteDatabase db = getReadableDatabase();
        List<Item> output = new ArrayList<>();
        try (Cursor c = db.query(T_ITEMS, null, null, null, null, null, C_UPDATED_AT + " DESC")) {
            int xId = c.getColumnIndexOrThrow(C_ID);
            int xName = c.getColumnIndexOrThrow(C_NAME);
            int xQty = c.getColumnIndexOrThrow(C_QTY);
            int xLoc = c.getColumnIndexOrThrow(C_LOCATION);

            while(c.moveToNext()) {
                output.add(new Item(
                        c.getLong(xId),
                        c.getString(xName),
                        c.getInt(xQty),
                        c.getString(xLoc)
                ));
            }
        }

        return output;
    }
}
