//
//  NotificationSettingsViewModel.swift
//  Inventory App
//
//  Created by Connor Bailey on 11/26/25.
//

import UserNotifications
import UIKit
import Combine

// Manages system notification permission status, the app toggle,
// and a persistent list of notifications
final class NotificationSettingsViewModel: ObservableObject {
    @Published var isNotificationsEnabled: Bool = false
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published var notifications: [InventoryNotification] = []
    
    // UserDefaults keys
    private let enabledKey = "InventoryApp.notificationsEnabled"
    private let notificationKey = "InventoryApp.notifications"
    // Tracks the last known percent remaining for each item so we can detect threshold crossings
    private let lastKnownPercentKey = "InventoryApp.lastKnownPercentByItemId"
    private let lowStockThresholdPercent: Int = 20

    // itemId (uuid string) -> last known percent remaining
    private var lastKnownPercentByItemId: [String: Int] = [:]
    
    init() {
        loadSettings()
        loadNotifications()
        loadLastKnownPercents()
        refreshAuthorizationStatus()
    }
    
    // MARK: - Public API

    /// Call this after the app refreshes inventory items from the server.
    /// This allows *any* client (not only the one that made the change) to generate a low-stock notification
    /// when an item crosses the threshold.
    ///
    /// Behavior: we only notify on a transition from > threshold to <= threshold to avoid repeated alerts.
    /// On the first ever refresh (no cache yet), we just seed the cache and do not spam notifications.
    func handleInventoryRefresh(items: [InventoryItem]) {
        // Seed on first run to avoid a burst of notifications when the app first loads.
        if lastKnownPercentByItemId.isEmpty {
            var seeded: [String: Int] = [:]
            for item in items {
                let percent = percentRemaining(quantity: item.quantity, maxQuantity: item.maxQuantity)
                seeded[item.id.uuidString] = percent
            }
            lastKnownPercentByItemId = seeded
            saveLastKnownPercents()
            return
        }

        var updated = lastKnownPercentByItemId

        for item in items {
            let itemId = item.id.uuidString
            let newPercent = percentRemaining(quantity: item.quantity, maxQuantity: item.maxQuantity)
            let oldPercent = updated[itemId] ?? 101 // treat unknown as "above threshold"

            // Notify only when we cross the threshold downward
            if oldPercent > lowStockThresholdPercent && newPercent <= lowStockThresholdPercent {
                sendLowStockNotification(
                    itemName: item.name,
                    itemLocation: item.location,
                    percentRemaining: newPercent
                )
            }

            updated[itemId] = newPercent
        }

        // Remove cache entries for items that no longer exist
        let currentIds = Set(items.map { $0.id.uuidString })
        updated.keys
            .filter { !currentIds.contains($0) }
            .forEach { updated.removeValue(forKey: $0) }

        lastKnownPercentByItemId = updated
        saveLastKnownPercents()
    }
    
    // Called when the user toggles the "Enabled Notifications" switch
    func handleToggleChange(_ isOn: Bool) {
        if isOn {
            requestAuthorizationIfNeeded()
        } else {
            // App level preference
            isNotificationsEnabled = false
            saveSettings()
        }
    }
    
    // Refresh the system authorization status
    func refreshAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            // Get authorization status asyncronously
            DispatchQueue.main.async {
                self.authorizationStatus = settings.authorizationStatus
                
                // If the system no longer authorizes notifications
                // we keep the app level toggle in sync
                if settings.authorizationStatus != .authorized {
                    self.isNotificationsEnabled = false
                }
            }
        }
    }
    
    var authorizationStatusText: String {
        switch authorizationStatus {
            case .notDetermined:
                return "Not Determined"
            case .denied:
                return "Denied"
            case .authorized:
                return "Authorized"
            case .provisional:
                return "Provisional"
            case .ephemeral:
                return "Ephemeral"
            @unknown default:
                return "Unknown"
        }
    }
    
    // Function to call when an item drops below the threshold to notify the user
    func sendLowStockNotification(itemName: String, itemLocation: String, percentRemaining: Int) {
        // Guard the app level toggle and the system authorization, must allow both
        guard isNotificationsEnabled && (authorizationStatus == .authorized || authorizationStatus == .provisional) else {
            return
        }
        
        // Schedule the system push notification
        let content = UNMutableNotificationContent()
        content.title = "Low Stock Alert"
        content.body = "\(itemName) in \(itemLocation) is down to \(percentRemaining)% of its capacity."
        content.sound = .default
        
        // Trigger is the time interval before the notification is displayed to the user
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "lowStock-\(itemName)-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        // Add an entry to the in-app notification history
        let newNotification = InventoryNotification(
            id: UUID(),
            title: content.title,
            message: content.body,
            date: Date(),
            isRead: false
        )
        
        // Update notifications asyncronously
        DispatchQueue.main.async {
            self.notifications.insert(newNotification, at: 0)
            self.saveNotifications()
        }
    }
    
    // MARK: - Inventory Threshold Helpers

    private func percentRemaining(quantity: Int, maxQuantity: Int) -> Int {
        guard maxQuantity > 0 else { return 0 }
        let pct = (Double(quantity) / Double(maxQuantity)) * 100.0
        return max(0, min(100, Int(pct.rounded())))
    }

    private func loadLastKnownPercents() {
        let defaults = UserDefaults.standard
        guard let data = defaults.data(forKey: lastKnownPercentKey) else {
            lastKnownPercentByItemId = [:]
            return
        }

        if let decoded = try? JSONDecoder().decode([String: Int].self, from: data) {
            lastKnownPercentByItemId = decoded
        } else {
            lastKnownPercentByItemId = [:]
        }
    }

    private func saveLastKnownPercents() {
        let defaults = UserDefaults.standard
        if let data = try? JSONEncoder().encode(lastKnownPercentByItemId) {
            defaults.set(data, forKey: lastKnownPercentKey)
        }
    }
    
    // MARK: - Settings Helpers
    
    // Loads settings from UserDefaults
    private func loadSettings() {
        let defaults = UserDefaults.standard
        
        if defaults.object(forKey: enabledKey) != nil {
            isNotificationsEnabled = defaults.bool(forKey: enabledKey)
        } else {
            isNotificationsEnabled = false
        }
    }
    
    // Saves settings to UserDefaults
    private func saveSettings() {
        let defaults = UserDefaults.standard
        defaults.set(isNotificationsEnabled, forKey: enabledKey)
    }
    
    // Requests Push Notification Permission from the system
    private func requestAuthorizationIfNeeded() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                // Ask the system for permission
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
                    // Asyncronously grant permission and refresh the auth status
                    DispatchQueue.main.async {
                        self.isNotificationsEnabled = granted
                        self.saveSettings()
                        self.refreshAuthorizationStatus()
                    }
                }
                
            case .denied:
                // This cannot be changed at the app level
                DispatchQueue.main.async {
                    self.isNotificationsEnabled = false
                    self.saveSettings()
                    self.authorizationStatus = .denied
                }
                
            default:
                // Permission is already determined, just mirror the current state
                DispatchQueue.main.async {
                    let isAuthorized = (settings.authorizationStatus == .authorized)
                    self.isNotificationsEnabled = isAuthorized
                    self.saveSettings()
                    self.authorizationStatus = settings.authorizationStatus
                }
            }
        }
    }
    
    // MARK: - Notification actions
    
    /// Marks a notification as read and persists the change.
    func markAsRead(_ notification: InventoryNotification) {
        if let index = notifications.firstIndex(of: notification) {
            if notifications[index].isRead == false {
                notifications[index].isRead = true
                saveNotifications()
            }
        }
    }
    
    /// Marks a notification as unread and persists the change.
    func markAsUnread(_ notification: InventoryNotification) {
        if let index = notifications.firstIndex(of: notification) {
            if notifications[index].isRead == true {
                notifications[index].isRead = false
                saveNotifications()
            }
        }
    }
    
    /// Deletes a notification and persists the change.
    func deleteNotification(_ notification: InventoryNotification) {
        if let index = notifications.firstIndex(of: notification) {
            notifications.remove(at: index)
            saveNotifications()
        }
    }
    
    // MARK: - Notifications Storage Helpers
    
    // Loads notifications from UserDefaults
    private func loadNotifications() {
        let defaults = UserDefaults.standard
        
        if let data = defaults.data(forKey: notificationKey), let decoded = try? JSONDecoder().decode([InventoryNotification].self, from: data) {
            notifications = decoded
        } else {
            // Seed the UI with three example notifications
            seedTestNotifications()
        }
    }
    
    // Saves a new notification to UserDefaults
    private func saveNotifications() {
        let defaults = UserDefaults.standard
        if let data = try? JSONEncoder().encode(notifications) {
            defaults.set(data, forKey: notificationKey)
        }
    }
    
    // Seed the UI with these notifications on first launch
    private func seedTestNotifications() {
        let now = Date()
        let seeded: [InventoryNotification] = [
            InventoryNotification(
                id: UUID(),
                title: "Welcome to InventoryApp",
                message: "This is your first notification!",
                date: now.addingTimeInterval(-3600), // 1 hour ago
                isRead: false
            ),
            InventoryNotification(
                id: UUID(),
                title: "InventoryApp Notifications",
                message: "Here you will find important notifications and alerts about your warehouses inventory levels.",
                date: now.addingTimeInterval(-3540), // 59 minutes ago
                isRead: false
            ),
            InventoryNotification(
                id: UUID(),
                title: "InventoryApp Push Notifications",
                message: "Make sure to enable push notifications to stay updated while outside the app.",
                date: now.addingTimeInterval(-3480), // 58 minutes ago
                isRead: false
            )
        ]
        
        notifications = seeded
        saveNotifications()
    }
}
