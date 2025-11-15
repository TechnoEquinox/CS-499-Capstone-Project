//
//  NotificationsView.swift
//  Inventory App
//
//  Created by Connor Bailey on 11/14/25.
//

import SwiftUI

struct NotificationsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Notifications")
                .font(.largeTitle.bold())
            
            Text("Not Implemented")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        NotificationsView()
    }
}
