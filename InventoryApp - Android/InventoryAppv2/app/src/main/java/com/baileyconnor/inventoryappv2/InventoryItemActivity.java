package com.baileyconnor.inventoryappv2;

import android.os.Bundle;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;
import android.view.MenuItem;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;
import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;

import com.baileyconnor.inventoryappv2.database.DatabaseHelper;
import com.baileyconnor.inventoryappv2.model.Item;
public class InventoryItemActivity extends AppCompatActivity {

    public static final String ITEM_ID = "item_id";

    private DatabaseHelper db;
    private long itemId = -1L;
    private Item item;

    private TextView itemName, itemAmountAnswerText, itemLocationAnswerText;
    private Button adjustQuantityItemButton, adjustLocationButton, deleteItemButton;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.inventory_item);

        // Bind the views
        itemName = findViewById(R.id.itemName);
        itemAmountAnswerText = findViewById(R.id.itemAmountAnswerText);
        itemLocationAnswerText = findViewById(R.id.itemLocationAnswerText);
        adjustQuantityItemButton = findViewById(R.id.adjustQuantityItemButton);
        adjustLocationButton = findViewById(R.id.adjustLocationButton);
        deleteItemButton = findViewById(R.id.deleteItemButton);

        // Initialize the database and load the item from intent
        db = new DatabaseHelper(this);
        itemId = getIntent().getLongExtra(ITEM_ID, -1L);
        if (itemId == -1L) {
            Toast.makeText(this, "No item id provided", Toast.LENGTH_SHORT).show();
            finish();
            return;
        }

        item = db.getItemById(itemId);
        if (item == null) {
            Toast.makeText(this, "Item not found", Toast.LENGTH_SHORT).show();
            finish();
            return;
        }

        // Populate the current values fetched from the database
        itemName.setText(item.getName());
        itemAmountAnswerText.setText(String.valueOf(item.getQuantity()));
        itemLocationAnswerText.setText(item.getLocation());

        if (getSupportActionBar() != null) {
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
            getSupportActionBar().setTitle(item.getName());
        }

        // Button Event Listeners
        adjustQuantityItemButton.setOnClickListener(v -> {
            final EditText input = new EditText(this);
            input.setHint("Enter a new quantity for the item");

            // Prompt the user to change the value
            new AlertDialog.Builder(this)
                    .setTitle("Adjust Quantity")
                    .setView(input)
                    .setPositiveButton("Save", (dialog, which) -> {
                        String text = input.getText().toString().trim();
                        int newQuantity;
                        // Parse the input and verify it is a Int
                        try {
                            newQuantity = Integer.parseInt(text);
                        } catch (Exception error) {
                            Toast.makeText(this, "Please enter a valid number", Toast.LENGTH_SHORT).show();
                            return;
                        }

                        // Update the model and DB
                        item.setQuantity(newQuantity);
                        db.updateItem(item);

                        // Update the UI
                        itemAmountAnswerText.setText(String.valueOf(newQuantity));
                        Toast.makeText(this, "Quantity updated to: " + newQuantity, Toast.LENGTH_SHORT).show();
                    })
                    .setNegativeButton("Cancel", null)
                    .show();
        });

        adjustLocationButton.setOnClickListener(v -> {
            final EditText input = new EditText(this);
            input.setHint("Enter a new location for the item");

            // Prompt the user to change the value
            new AlertDialog.Builder(this)
                    .setTitle("Adjust Location")
                    .setView(input)
                    .setPositiveButton("Save", (dialog, which) -> {
                        String newLocation = input.getText().toString().trim();

                        // Update the model and the database
                        item.setLocation(newLocation);
                        db.updateItem(item);

                        // Update the UI
                        itemLocationAnswerText.setText(newLocation);
                        Toast.makeText(this, "Location updated to: " + newLocation, Toast.LENGTH_SHORT).show();
                    })
                    .setNegativeButton("Cancel", null)
                    .show();
        });

        deleteItemButton.setOnClickListener(v -> new AlertDialog.Builder(this)
                .setTitle("Delete Item")
                .setMessage("Are you sure you want to delete this item?")
                .setPositiveButton("Yes", (dialog, which) -> {
                    db.deleteItem(itemId);
                    Toast.makeText(this, "Item Deleted", Toast.LENGTH_SHORT).show();
                    finish();
                })

                .setNegativeButton("Cancel", null)
                .show());
    }

    @Override
    public boolean onOptionsItemSelected(@NonNull MenuItem item) {
        if (item.getItemId() == android.R.id.home) {
            finish();
            return true;
        }
        return super.onOptionsItemSelected(item);
    }
}
