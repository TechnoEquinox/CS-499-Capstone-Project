//
//  NotificationRow.swift
//  Inventory App
//
//  Created by Connor Bailey on 11/26/25.
//

import SwiftUI

struct NotificationRow: View {
    let notification: InventoryNotification
    
    private static var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: notification.isRead ? "bell" : "bell.badge.fill")
                .imageScale(.large)
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.title)
                    .font(.headline)
                
                Text(notification.message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text(Self.dateFormatter.string(from: notification.date))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NotificationRow(notification: InventoryNotification(
        id: UUID(),
        title: "Welcome to InventoryApp",
        message: "This is your first notification!",
        date: Date(),
        isRead: false
    ))
}
