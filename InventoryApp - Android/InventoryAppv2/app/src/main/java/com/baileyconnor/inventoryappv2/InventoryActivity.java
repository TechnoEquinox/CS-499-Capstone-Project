package com.baileyconnor.inventoryappv2;

import android.content.Intent;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.Toast;
import com.google.android.material.floatingactionbutton.FloatingActionButton;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.text.InputType;
import android.app.AlertDialog;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.baileyconnor.inventoryappv2.database.DatabaseHelper;
import com.baileyconnor.inventoryappv2.model.Item;

import java.util.List;

public class InventoryActivity extends AppCompatActivity {

    private DatabaseHelper db;
    private InventoryAdapter adapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_inventory);

        db = new DatabaseHelper(this);

        RecyclerView inventoryRecycler = findViewById(R.id.inventoryRecycler);
        inventoryRecycler.setLayoutManager(new GridLayoutManager(this, 2));

        adapter = new InventoryAdapter(db.getAllItems(), new InventoryAdapter.Listener() {
            @Override public void onClick(Item item) {
                Intent i = new Intent(InventoryActivity.this, InventoryItemActivity.class);
                i.putExtra(InventoryItemActivity.ITEM_ID, item.getId());
                startActivity(i);
            }
            @Override public void onLongPress(Item item) {
                new android.app.AlertDialog.Builder(InventoryActivity.this)
                        .setTitle("Delete item")
                        .setMessage("Delete \"" + item.getName() + "\"?")
                        .setPositiveButton("Delete", (d, w) -> {
                            db.deleteItem(item.getId());
                            refresh();
                        })
                        .setNegativeButton("Cancel", null)
                        .show();
            }
        });
        inventoryRecycler.setAdapter(adapter);

        // Floating Action Button
        FloatingActionButton fab = findViewById(R.id.floatingActionButton);
        fab.setOnClickListener(v -> {
            // Small form with three inputs
            final EditText name = new EditText(this);
            name.setHint("Name");

            final EditText qty = new EditText(this);
            qty.setHint("Quantity");
            qty.setInputType(InputType.TYPE_CLASS_NUMBER);

            final EditText loc = new EditText(this);
            loc.setHint("Location");

            LinearLayout container = new LinearLayout(this);
            container.setOrientation(LinearLayout.VERTICAL);
            int pad = (int) (16 * getResources().getDisplayMetrics().density);
            container.setPadding(pad, pad, pad, pad);
            container.addView(name);
            container.addView(qty);
            container.addView(loc);

            new AlertDialog.Builder(this)
                    .setTitle("Add Item")
                    .setView(container)
                    .setPositiveButton("Save", (d, w) -> {
                        String n = name.getText().toString().trim();
                        String qStr = qty.getText().toString().trim();
                        String l = loc.getText().toString().trim();

                        if (n.isEmpty() || qStr.isEmpty()) {
                            Toast.makeText(this, "Name and Quantity are required", Toast.LENGTH_SHORT).show();
                            return;
                        }
                        int q = Integer.parseInt(qStr);

                        long newId = db.insertItem(new Item(n, q, l));

                        if (newId == -1) {
                            Toast.makeText(this, "Failed to add item", Toast.LENGTH_LONG).show();
                        } else {
                            Toast.makeText(this, "Added: " + n, Toast.LENGTH_SHORT).show();
                            refresh();
                        }
                    })
                    .setNegativeButton("Cancel", null)
                    .show();
        });

        // Initialize the database with sample values if it is empty
        if (adapter.getItemCount() == 0) {
            db.insertItem(new Item(1, "Boxes", 17, "Bay 4"));
            db.insertItem(new Item(2, "Tape", 29, "Bay 7"));
            db.insertItem(new Item(3, "Nails", 103, "Bay 4"));
            db.insertItem(new Item(4, "Paper Cups", 51, "Bay 1"));
            db.insertItem(new Item(5, "Apple Magic Keyboard", 6, "Bay 2"));
            db.insertItem(new Item(6, "Apple Magic Trackpad", 7, "Bay 2"));
            db.insertItem(new Item(7, "Apple Magic Mouse", 6, "Bay 2"));
            db.insertItem(new Item(8, "Lightning Cable (1M)", 24, "Bay 3"));
            db.insertItem(new Item(9, "USB-C Cable (1M)", 25, "Bay 2"));
            refresh();
        }
    }

    private void refresh() {
        List<Item> all = db.getAllItems();
        Toast.makeText(this, "Items: " + all.size(), Toast.LENGTH_SHORT).show();
        adapter.submit(all);
    }

    @Override
    protected void onResume() {
        super.onResume();
        refresh();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.inventory_menu, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem menuItem) {
        if (menuItem.getItemId() == R.id.action_notifications) {
            startActivity(new Intent(this, NotificationsActivity.class));
            return true;
        }
        return super.onOptionsItemSelected(menuItem);
    }
}