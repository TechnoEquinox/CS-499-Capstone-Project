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
    
    private var nextId: Int = 1
    
    init() {
        seedIfEmpty()
    }
    
    // TODO: Remove this function once the database is setup
    private func seedIfEmpty() {
        // Check if items is empty, return if it is not
        guard items.isEmpty else { return }
        
        let seeded: [InventoryItem] = [
            InventoryItem(id: 1, name: "Boxes", quantity: 17, location: "Bay 4"),
            InventoryItem(id: 2, name: "Tape", quantity: 29, location: "Bay 7"),
            InventoryItem(id: 3, name: "Nails", quantity: 103, location: "Bay 4"),
            InventoryItem(id: 4, name: "Paper Cups", quantity: 51, location: "Bay 1"),
            InventoryItem(id: 5, name: "Apple Magic Keyboard", quantity: 6, location: "Bay 2"),
            InventoryItem(id: 6, name: "Apple Magic Trackpad", quantity: 7, location: "Bay 2"),
            InventoryItem(id: 7, name: "Apple Magic Mouse", quantity: 6, location: "Bay 2"),
            InventoryItem(id: 8, name: "Lightning Cable (1M)", quantity: 24, location: "Bay 3"),
            InventoryItem(id: 9, name: "USB-C Cable (1M)", quantity: 25, location: "Bay 2")
        ]
        
        // Assin our seed to populate the application
        items = seeded
        
        // Assign nextId to the next ID after our seeded values
        nextId = (seeded.map { $0.id }.max() ?? 0) + 1
    }
    
    // TODO: This is temporary code to simulate database entry
    func addItem(name: String, quantity: Int, location: String) {
        let item = InventoryItem(id: nextId, name: name, quantity: quantity, location: location)
        nextId += 1
        items.append(item)
    }
    
    // TODO: This is temporary code to simulate database deletion
    func deleteItem(_ item: InventoryItem) {
        items.removeAll { $0.id == item.id }
    }
}
