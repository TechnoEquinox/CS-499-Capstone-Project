//
//  InventoryView.swift
//  Inventory App
//
//  Created by Connor Bailey on 11/14/25.
//

import SwiftUI

struct InventoryView: View {
    @StateObject private var viewModel = InventoryViewModel()
    
    @State private var showingAddItem = false
    @State private var itemToDelete: InventoryItem?
    @State private var showingDeleteAlert = false
    
    @State private var isEditing = false
    @State private var selectedItemIDs = Set<UUID>()
    @State private var showingBatchDeleteAlert = false
    
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
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(viewModel.items) { item in
                            
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
                                        InventoryItemDetailView(item: item)
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
                ToolbarItem(placement: .topBarLeading) {
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
                        Image(systemName: "bell")
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
            .sheet(isPresented: $showingAddItem) {
                AddItemView { name, quantity, location in
                    viewModel.addItem(name: name, quantity: quantity, location: location)
                }
            }
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
}
