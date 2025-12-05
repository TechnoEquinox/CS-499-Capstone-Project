//
//  DeleteItemPayload.swift
//  Inventory App
//
//  Created by Connor Bailey on 12/4/25.
//

import Foundation

// Helper payload for delete-item route
public struct DeleteItemPayload: Codable {
    let id: String
}
