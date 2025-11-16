//
//  InventoryViewModel.swift
//  Inventory App
//
//  Created by Connor Bailey on 11/14/25.
//

import Foundation
import SwiftUI
internal import Combine

@MainActor
class InventoryViewModel: ObservableObject {
    @Published var items: [InventoryItem] = []
    
    init() {
        seedIfEmpty()
    }
    
    // TODO: Remove this function once the database is setup
    private func seedIfEmpty() {
        // Check if items is empty, return if it is not
        guard items.isEmpty else { return }
        
        let seeded: [InventoryItem] = [
            InventoryItem(name: "Boxes", quantity: 95, maxQuantity: 100, location: "Bay 4", symbolName: "shippingbox"),
            InventoryItem(name: "Tape", quantity: 29, maxQuantity: 100, location: "Bay 4", symbolName: "wrench"),
            InventoryItem(name: "Nails", quantity: 403, maxQuantity: 1000, location: "Bay 4", symbolName: "wrench"),
            InventoryItem(name: "Paper Cups", quantity: 51, maxQuantity: 200, location: "Bay 4", symbolName: "questionmark"),
            InventoryItem(name: "Apple Magic Keyboard", quantity: 6, maxQuantity: 50, location: "Bay 2", symbolName: "keyboard"),
            InventoryItem(name: "Apple Magic Trackpad", quantity: 7, maxQuantity: 50, location: "Bay 2", symbolName: "computermouse"),
            InventoryItem(name: "Apple Magic Mouse", quantity: 6, maxQuantity: 50, location: "Bay 2", symbolName: "computermouse"),
            InventoryItem(name: "Lightning Cable (1M)", quantity: 24, maxQuantity: 100, location: "Bay 3", symbolName: "cable.connector"),
            InventoryItem(name: "USB-C Cable (1M)", quantity: 25, maxQuantity: 100, location: "Bay 3", symbolName: "cable.connector"),
            InventoryItem(name: "USB-A Cable (1M)", quantity: 37, maxQuantity: 100, location: "Bay 3", symbolName: "cable.connector"),
            InventoryItem(name: "Kingston 1TB SSD", quantity: 44, maxQuantity: 150, location: "Bay 7", symbolName: "externaldrive"),
            InventoryItem(name: "Kingston 2TB SSD", quantity: 41, maxQuantity: 150, location: "Bay 7", symbolName: "externaldrive"),
            InventoryItem(name: "Segate 1TB SSD", quantity: 66, maxQuantity: 150, location: "Bay 7", symbolName: "externaldrive"),
            InventoryItem(name: "Segate 2TB SSD", quantity: 87, maxQuantity: 150, location: "Bay 7", symbolName: "externaldrive"),
        ]
        
        // Assin our seed to populate the application
        items = seeded
    }
    
    // TODO: This is temporary code to simulate database entry
    func addItem(name: String, quantity: Int, maxQuantity: Int, location: String) {
        let item = InventoryItem(name: name, quantity: quantity, maxQuantity: maxQuantity, location: location, symbolName: "questionmark")
        items.append(item)
    }
    
    // TODO: This is temporary code to simulate database deletion
    func deleteItem(_ item: InventoryItem) {
        items.removeAll { $0.id == item.id }
    }
}
