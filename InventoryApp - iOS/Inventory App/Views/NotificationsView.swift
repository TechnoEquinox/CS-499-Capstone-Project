//
//  NotificationsView.swift
//  Inventory App
//
//  Created by Connor Bailey on 11/14/25.
//

import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject var viewModel: NotificationSettingsViewModel
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        List {
            settingsSection
            
            // Only show the notification section if the user enabled notifications
            if viewModel.isNotificationsEnabled {
                notificationSection
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Sections
    
    private var settingsSection: some View {
        Section("Notification Settings") {
            Toggle(isOn: Binding(
                get: { viewModel.isNotificationsEnabled },
                set: { viewModel.handleToggleChange($0) }
            )) {
                Label(
                    "Enable Notifications",
                    systemImage: viewModel.isNotificationsEnabled ? "bell.fill" : "bell"
                )
            }
            
            HStack {
                Text("System Permission")
                Spacer()
                Text(viewModel.authorizationStatusText)
                    .foregroundStyle(.secondary)
            }
            
            if viewModel.authorizationStatus == .denied {
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        openURL(url)
                    }
                } label: {
                    Label("Open Settings", systemImage: "gear")
                }
            }
        }
    }
    
    
    private var notificationSection: some View {
        Section("Notification History") {
            if viewModel.notifications.isEmpty {
                ContentUnavailableView(
                    "No New Notifications",
                    systemImage: "bell.badge",
                    description: Text("When there is a new alert, you will see it listed here.")
                )
            } else {
                ForEach(viewModel.notifications.sorted(by: { $0.date > $1.date })) { notification in
                    NotificationRow(notification: notification)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            if notification.isRead {
                                Button {
                                    viewModel.markAsUnread(notification)
                                } label: {
                                    Label("Unread", systemImage: "envelope.badge")
                                }
                            } else {
                                Button {
                                    viewModel.markAsRead(notification)
                                } label: {
                                    Label("Read", systemImage: "envelope.open")
                                }
                            }
                            
                            Button(role: .destructive) {
                                viewModel.deleteNotification(notification)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        NotificationsView()
            .environmentObject(NotificationSettingsViewModel())
    }
}
