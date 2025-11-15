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
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(viewModel.items) { item in
                            NavigationLink {
                                InventoryItemDetailView(item: item)
                            } label: {
                                InventoryItemCardView(item: item)
                            }
                            .onLongPressGesture {
                                itemToDelete = item
                                showingDeleteAlert = true
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    InventoryView()
}
