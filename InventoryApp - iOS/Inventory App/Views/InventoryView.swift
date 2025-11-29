//
//  InventoryView.swift
//  Inventory App
//
//  Created by Connor Bailey on 11/14/25.
//

import SwiftUI

struct InventoryView: View {
    @StateObject private var viewModel = InventoryViewModel()
    @EnvironmentObject private var notificationViewModel: NotificationSettingsViewModel
    
    @State private var showingAddItem = false
    @State private var itemToDelete: InventoryItem?
    @State private var showingDeleteAlert = false
    
    @State private var isEditing = false
    @State private var selectedItemIDs = Set<UUID>()
    @State private var showingBatchDeleteAlert = false
    @State private var selectedLocationFilter: String? = nil
    @State private var lowStockOnly: Bool = false
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    private func toggleSelection(for item: InventoryItem) {
        if selectedItemIDs.contains(item.id) {
            selectedItemIDs.remove(item.id)
        } else {
            selectedItemIDs.insert(item.id)
        }
    }
    
    private func deleteSelectedItems() {
        viewModel.items.removeAll { item in
            selectedItemIDs.contains(item.id)
        }
        selectedItemIDs.removeAll()
        isEditing = false
    }
    
    // Gets each unique location in our ItemInventory data structure
    private var availableLocations: [String] {
        let locations = viewModel.items
            .map { $0.location.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return Array(Set(locations)).sorted()
    }
    
    // Counts the number of unread notifications
    private var notificationCount: Int {
        notificationViewModel.notifications.filter { $0.isRead == false }.count
    }
    
    private var notificationBadgeText: String {
        if notificationCount > 8 {
            return "9+"
        } else {
            return "\(notificationCount)"
        }
    }

    private var filteredItems: [InventoryItem] {
        // Filter by location if a location filter is selected
        let baseItems: [InventoryItem]
        if let selected = selectedLocationFilter {
            baseItems = viewModel.items.filter {
                $0.location.trimmingCharacters(in: .whitespacesAndNewlines) == selected
            }
        } else {
            baseItems = viewModel.items
        }
        
        // Optionally filter by low stock
        if lowStockOnly {
            return baseItems.filter { item in
                guard item.maxQuantity > 0 else { return false }
                let ratio = Double(item.quantity) / Double(item.maxQuantity)
                return ratio < 0.40
            }
        } else {
            return baseItems
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                
                // Full screen gray
                Color(.systemGray)
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(filteredItems) { item in
                            
                            let isSelected = selectedItemIDs.contains(item.id)
                            
                            Group {
                                if isEditing {
                                    Button {
                                        toggleSelection(for: item)
                                    } label: {
                                        InventoryItemCardView(item: item)
                                            .overlay(alignment: .topTrailing) {
                                                if isSelected {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .imageScale(.large)
                                                        .padding(6)
                                                }
                                            }
                                            .opacity(isSelected ? 0.8 : 1.0)
                                    }
                                    .buttonStyle(.plain)
                                } else {
                                    NavigationLink {
                                        InventoryItemDetailView(item: item) { updatedItem in
                                            if let index = viewModel.items.firstIndex(where: { $0.id == item.id }) {
                                                viewModel.items[index] = updatedItem
                                            }
                                        }
                                    } label: {
                                        InventoryItemCardView(item: item)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            // Toolbar at the top of the page
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isEditing ? "Done" : "Edit") {
                        if isEditing {
                            isEditing = false
                            selectedItemIDs.removeAll()
                        } else {
                            isEditing = true
                        }
                    }
                }
                
                ToolbarItemGroup(placement: .topBarTrailing) {
                    NavigationLink {
                        NotificationsView()
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "bell")
                            
                            if notificationViewModel.isNotificationsEnabled && notificationCount > 0 {
                                Text(notificationBadgeText)
                                    .font(.caption2).bold()
                                    .foregroundColor(.white)
                                    .padding(4)
                                    .background(
                                        Circle()
                                            .fill(Color.red)
                                    )
                                    .offset(x: 6, y: -6)
                            }
                        }
                    }
                    
                    Menu {
                        Button("All Items") {
                            selectedLocationFilter = nil
                            lowStockOnly = false
                        }
                        
                        Button("Low Stock") {
                            selectedLocationFilter = nil
                            lowStockOnly = true
                        }
                        
                        Section("Locations") {
                            ForEach(availableLocations, id: \.self) { location in
                                Button(location) {
                                    selectedLocationFilter = location
                                    lowStockOnly = false
                                }
                            }
                        }
                        
                    } label: {
                        if lowStockOnly {
                            Label("Low Stock", systemImage: "line.3.horizontal.decrease.circle.fill")
                        } else if let selected = selectedLocationFilter {
                            Label(selected, systemImage: "line.3.horizontal.decrease.circle.fill")
                        } else {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                        }
                    }
                    
                    if isEditing {
                        Button(role: .destructive) {
                            if !selectedItemIDs.isEmpty {
                                showingBatchDeleteAlert = true
                            }
                        } label: {
                            Image(systemName: "trash")
                        }
                        .disabled(selectedItemIDs.isEmpty)
                    }
                    
                    Button {
                        showingAddItem = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            // Present the AddItemView as a sheet
            .sheet(isPresented: $showingAddItem) {
                AddItemView { name, quantity, maxQuantity, location in
                    viewModel.addItem(name: name, quantity: quantity, maxQuantity: maxQuantity, location: location)
                }
            }
            // Present an alert to the user before deleting
            .alert("Delete selected items?", isPresented: $showingBatchDeleteAlert) {
                Button("Delete", role: .destructive) {
                    deleteSelectedItems()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will delete \(selectedItemIDs.count) item(s). This action cannot be undone.")
            }
        }
    }
}

#Preview {
    InventoryView()
        .environmentObject(NotificationSettingsViewModel())
}
