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
    
    private var fillFraction: CGFloat {
        guard item.maxQuantity > 0 else { return 0 }
        let ratio = Double(item.quantity) / Double(item.maxQuantity)
        let clamped = min(max(ratio, 0), 1)
        return CGFloat(clamped)
    }
    
    private var fillColor: Color {
        switch fillFraction {
        case ..<0.20:
            return Color.red.opacity(0.3)
        case 0.20..<0.40:
            return Color.yellow.opacity(0.3)
        case 0.40..<0.90:
            return Color.blue.opacity(0.3)
        default:
            return Color.green.opacity(0.3)
        }
    }
    
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
            GeometryReader { geo in
                let height = geo.size.height * fillFraction
                
                ZStack {
                    ZStack(alignment: .bottom) {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(.systemBackground))
                            .shadow(radius: 4)
                        
                        Rectangle()
                            .fill(fillColor)
                            .frame(height: height)
                    }
                    
                    // Symbol in bottom-right corner
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(systemName: item.symbolName)
                                .font(.system(size: 24))
                                .foregroundStyle(.secondary)
                                .padding(8)
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        )
    }
}

#Preview {
    InventoryItemCardView(
        item: InventoryItem(name: "Apple Magic Keyboard", quantity: 17, maxQuantity: 20, location: "Bay 4")
    )
    .padding()
    .background(Color(.systemGray))
}
