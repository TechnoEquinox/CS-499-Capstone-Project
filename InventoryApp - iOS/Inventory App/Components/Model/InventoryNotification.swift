//
//  InventoryNotification.swift
//  Inventory App
//
//  Created by Connor Bailey on 11/26/25.
//

import Foundation

// A codable model representing an in-app notification
struct InventoryNotification: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var message: String
    var date: Date
    var isRead: Bool
}
