package com.baileyconnor.inventoryappv2.model;

public class Item {
    private long id;
    private String name;
    private int quantity;
    private String location;

    // Constructor
    public Item(long id, String name, int quantity, String location) {
        this.id = id;
        this.name = name;
        this.quantity = quantity;
        this.location = location;
    }
    // Overloaded Constructor (location is optional)
    public Item(String name, int quantity) {
        this(0, name, quantity, "unknown");
    }

    public Item(String name, int quantity, String location) {
        this(0, name, quantity, location);
    }

    // Getters
    public long getId() { return  id; }
    public String getName() { return name; }
    public int getQuantity() { return quantity; }
    public String getLocation() { return location; }

    // Setters
    public void setId(long id) { this.id = id; }
    public void setName(String name) { this.name = name; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
    public void setLocation(String location) { this.location = location; }


}
