package com.baileyconnor.inventoryappv2;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.baileyconnor.inventoryappv2.database.DatabaseHelper;

public class MainActivity extends AppCompatActivity {

    private DatabaseHelper db;
    private EditText usernameEditText, passwordEditText;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_main);

        View root = findViewById(R.id.main);

        ViewCompat.setOnApplyWindowInsetsListener(root, (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        db = new DatabaseHelper(this);

        usernameEditText = findViewById(R.id.usernameEditText);
        passwordEditText = findViewById(R.id.passwordEditText);
        Button loginButton = findViewById(R.id.loginButton);
        Button createAccountButton = findViewById(R.id.createAccountButton);

        // --- --- Event Listeners --- --- \\

        // Login Button Event Listener
        loginButton.setOnClickListener( v -> {
            String u = usernameEditText.getText().toString().trim();
            String p = passwordEditText.getText().toString();

            // Check if either field is empty
            if (u.isEmpty() || p.isEmpty()) {
                Toast.makeText(this, "Enter username and password", Toast.LENGTH_SHORT).show();
                return;
            }

            // Validate the login attempt
            if (db.validateLogin(u, p)) {
                Toast.makeText(this, "Login successful", Toast.LENGTH_SHORT).show();
                // Move to the Inventory Activity
                startActivity(new Intent(this, InventoryActivity.class)); // FIX ME
                finish();
            } else {
                Toast.makeText(this, "Invalid Login Attempt", Toast.LENGTH_SHORT).show();
            }
        });

        // Create Account Button Listener
        createAccountButton.setOnClickListener(v -> {
            String u = usernameEditText.getText().toString().trim();
            String p = passwordEditText.getText().toString();

            // Check if either field is empty
            if (u.isEmpty() || p.isEmpty()) {
                Toast.makeText(this, "Enter username and password", Toast.LENGTH_SHORT).show();
                return;
            }
            // Store the result of the database operation
            boolean createUserAttempt = db.createUser(u, p);

            // Check the database operation
            if (createUserAttempt) {
                Toast.makeText(this, "Account created. Logging in...", Toast.LENGTH_SHORT).show();
                // Move to the Inventory Activity
                startActivity(new Intent(this, InventoryActivity.class));
                finish();
            } else {
                Toast.makeText(this, "Username already exists or an error occurred.", Toast.LENGTH_SHORT).show();
            }
        });
    }
}
