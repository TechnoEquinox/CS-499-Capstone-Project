//
//  InventoryItemCardView.swift
//  Inventory App
//
//  Created by Connor Bailey on 11/14/25.
//
// This view contains the layout for an individual item in our database
// that is displayed in InventoryView

import SwiftUI

struct InventoryItemCardView: View {
    let item: InventoryItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.name)
                .font(.headline)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
            
            Text("Qty: \(item.quantity)")
                .font(.subheadline)
            
            // Validate there is a location to display
            if !item.location.isEmpty {
                Text(item.location)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(radius: 4)
        )
    }
}

#Preview {
    InventoryItemCardView(
        item: InventoryItem(name: "Apple Magic Keyboard", quantity: 17, location: "Bay 4")
    )
    .padding()
    .background(Color(.systemGray))
}
