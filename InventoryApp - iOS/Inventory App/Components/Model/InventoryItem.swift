//
//  InventoryItem.swift
//  Inventory App
//
//  Created by Connor Bailey on 11/14/25.
//

import Foundation

struct InventoryItem: Identifiable, Hashable {
    let id: Int
    var name: String
    var quantity: Int
    var location: String
}
