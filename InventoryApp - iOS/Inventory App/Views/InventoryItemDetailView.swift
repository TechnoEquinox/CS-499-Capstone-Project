//
//  InventoryItemDetailView.swift
//  Inventory App
//
//  Created by Connor Bailey on 11/14/25.
//

import SwiftUI

struct InventoryItemDetailView: View {
    let item: InventoryItem
    
    var body: some View {
        Form {
            Section(header: Text("Name")) {
                Text(item.name)
            }
            
            Section(header: Text("Quantity")) {
                Text("\(item.quantity)")
            }
            
            Section(header: Text("Location")) {
                Text(item.location.isEmpty ? "-" : item.location)
            }
        }
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        InventoryItemDetailView(
            item: InventoryItem(id: 1, name: "Boxes", quantity: 17, location: "Bay 4")
        )
    }
}
