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
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    init() {}
    
    func loadItems() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let loaded = try await InventoryAPIClient.shared.getAllItems()
            await MainActor.run {
                self.items = loaded
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to load items: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func refreshFromServer() async {
        Task {
            await loadItems()
        }
    }
    
    // Add a new item via the backend API
    func addItem(name: String, quantity: Int, maxQuantity: Int, location: String) {
        let tempItem = InventoryItem(name: name, quantity: quantity, maxQuantity: maxQuantity, location: location, symbolName: "questionmark")
        
        items.append(tempItem)
        
        Task { @MainActor in
            do {
                let created = try await InventoryAPIClient.shared.addItem(item: tempItem)
                
                if let index = items.firstIndex(where: { $0.id == tempItem.id }) {
                    items[index] = created
                }
            } catch {
                // Roll back insert
                items.removeAll { $0.id == tempItem.id }
                errorMessage = "Failed to add item: \(error.localizedDescription)"
            }
        }
    }
    
    // Delete an item via the backend API
    func deleteItem(_ item: InventoryItem) {
        // Remove locally, then ask server
        items.removeAll { $0.id == item.id }
        
        Task { @MainActor in
            do {
                try await InventoryAPIClient.shared.deleteItem(id: item.id)
            } catch {
                // Re-insert if delete fails
                items.append(item)
                errorMessage = "Failed to delete item: \(error.localizedDescription)"
            }
        }
    }
    
    // Update an item via the backend API
    func updateItem(_ updatedItem: InventoryItem, originalItem: InventoryItem) {
        if let index = items.firstIndex(where: { $0.id == originalItem.id }) {
            items[index] = updatedItem
        }
        
        Task { @MainActor in
            do {
                _ = try await InventoryAPIClient.shared.updateItem(updatedItem)
            } catch {
                // Revert to the original item on failure
                if let index = items.firstIndex(where: { $0.id == updatedItem.id }) {
                    items[index] = originalItem
                }
                errorMessage = "Failed to update item: \(error.localizedDescription)"
            }
        }
    }
}
