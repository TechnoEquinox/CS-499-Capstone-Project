//
//  InventoryItem.swift
//  Inventory App
//
//  Created by Connor Bailey on 11/14/25.
//

import Foundation

struct InventoryItem: Identifiable, Hashable {
    let id: UUID = UUID()
    var name: String
    var quantity: Int
    var maxQuantity: Int
    var location: String
    var symbolName: String = "shippingbox"
}
