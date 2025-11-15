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
            InventoryItem(name: "Boxes", quantity: 17, location: "Bay 4"),
            InventoryItem(name: "Tape", quantity: 29, location: "Bay 7"),
            InventoryItem(name: "Nails", quantity: 103, location: "Bay 4"),
            InventoryItem(name: "Paper Cups", quantity: 51, location: "Bay 1"),
            InventoryItem(name: "Apple Magic Keyboard", quantity: 6, location: "Bay 2"),
            InventoryItem(name: "Apple Magic Trackpad", quantity: 7, location: "Bay 2"),
            InventoryItem(name: "Apple Magic Mouse", quantity: 6, location: "Bay 2"),
            InventoryItem(name: "Lightning Cable (1M)", quantity: 24, location: "Bay 3"),
            InventoryItem(name: "USB-C Cable (1M)", quantity: 25, location: "Bay 2")
        ]
        
        // Assin our seed to populate the application
        items = seeded
    }
    
    // TODO: This is temporary code to simulate database entry
    func addItem(name: String, quantity: Int, location: String) {
        let item = InventoryItem(name: name, quantity: quantity, location: location)
        items.append(item)
    }
    
    // TODO: This is temporary code to simulate database deletion
    func deleteItem(_ item: InventoryItem) {
        items.removeAll { $0.id == item.id }
    }
}
