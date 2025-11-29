//
//  InventoryItemDetailView.swift
//  Inventory App
//
//  Created by Connor Bailey on 11/14/25.
//

import SwiftUI

struct InventoryItemDetailView: View {
    let item: InventoryItem
    var onSave: ((InventoryItem) -> Void)?
    
    @EnvironmentObject var notificationSettings: NotificationSettingsViewModel
    
    // Hard coded threshold for Low Stock notifications
    private let lowStockThreshold: Double = 0.2
    
    @State private var isEditing: Bool = false
    @State private var editedName: String
    @State private var editedQuantity: String
    @State private var editedMaxQuantity: String
    @State private var editedLocation: String
    @State private var selectedSymbolName: String
    
    init(item: InventoryItem, onSave: ((InventoryItem) -> Void)? = nil) {
        self.item = item
        self.onSave = onSave
        
        // Initalize these values with the values from our InventoryItem
        _editedName = State(initialValue: item.name)
        _editedQuantity = State(initialValue: String(item.quantity))
        _editedMaxQuantity = State(initialValue: String(item.maxQuantity))
        _editedLocation = State(initialValue: item.location)
        _selectedSymbolName = State(initialValue: item.symbolName)
    }
    
    private func saveChanges() {
        let newQuantity = Int(editedQuantity) ?? item.quantity
        let newMaxQuantity = Int(editedMaxQuantity) ?? item.maxQuantity
        
        // Normalize the text fields
        editedQuantity = String(newQuantity)
        editedMaxQuantity = String(newMaxQuantity)
        
        // let updatedItem = InventoryItem(name: editedName, quantity: newQuantity, maxQuantity: newMaxQuantity, location: editedLocation, symbolName: selectedSymbolName)
        
        // Calculate the old and new percent remaining
        // Protect against divide by zero
        let oldPercentRemaining = Double(item.quantity) / Double(max(item.maxQuantity, 1))
        let newPercentRemaining = Double(newQuantity) / Double(max(newMaxQuantity, 1))
        
        if oldPercentRemaining >= lowStockThreshold, newPercentRemaining < lowStockThreshold {
            let percentRemainingInt = Int(newPercentRemaining * 100)
            notificationSettings.sendLowStockNotification(itemName: editedName, itemLocation: editedLocation, percentRemaining: percentRemainingInt)
        }
        
        let updatedItem = InventoryItem(
            name: editedName,
            quantity: newQuantity,
            maxQuantity: newMaxQuantity,
            location: editedLocation,
            symbolName: selectedSymbolName
        )
        
        onSave?(updatedItem)
        isEditing = false
    }
    
    private var symbolChoices: [String] {
        [
            "shippingbox",
            "cube",
            "archivebox",
            "wrench",
            "bag",
            "key",
            "doc.text",
            "keyboard",
            "computermouse",
            "headphones",
            "cable.connector",
            "questionmark",
            "desktopcomputer",
            "laptopcomputer",
            "externaldrive"
        ]
    }
    
    var body: some View {
        Color(.systemGray)
            .ignoresSafeArea()
            .overlay(
                VStack(spacing: 20) {
                    // Symbol at the top
                    if isEditing {
                        Menu {
                            ForEach(symbolChoices, id: \.self) { symbol in
                                Button {
                                    selectedSymbolName = symbol
                                } label: {
                                    Label("", systemImage: symbol)
                                }
                            }
                        } label: {
                            Image(systemName: selectedSymbolName)
                                .font(.system(size: 48))
                                .foregroundStyle(.primary)
                                .padding(.top, 16)
                        }
                    } else {
                        Image(systemName: selectedSymbolName)
                            .font(.system(size: 48))
                            .foregroundStyle(.primary)
                            .padding(.top, 16)
                    }
                    
                    // Form below the symbol
                    Form {
                        Section(header: Text("Name")) {
                            if isEditing {
                                TextField("Name", text: $editedName)
                            } else {
                                Text(editedName)
                            }
                        }
                        
                        Section(header: Text("Quantity")) {
                            if isEditing {
                                TextField("Quantity", text: $editedQuantity)
                                    .keyboardType(.numberPad)
                            } else {
                                Text(editedQuantity)
                            }
                        }
                        
                        Section(header: Text("Max Quantity")) {
                            if isEditing {
                                TextField("Max Quantity", text: $editedMaxQuantity)
                                    .keyboardType(.numberPad)
                            } else {
                                Text(editedMaxQuantity)
                            }
                        }
                        
                        Section(header: Text("Location")) {
                            if isEditing {
                                TextField("Location", text: $editedLocation)
                            } else {
                                Text(editedLocation.isEmpty ? "-" : editedLocation)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                }
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if isEditing {
                        Button("Save") {
                            saveChanges()
                        }
                    } else {
                        Button("Edit") {
                            isEditing = true
                        }
                    }
                }
            }
            .navigationTitle(item.name)
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        InventoryItemDetailView(
            item: InventoryItem(name: "Boxes", quantity: 17, maxQuantity: 30, location: "Bay 4")
        )
        .environmentObject(NotificationSettingsViewModel())
    }
}
