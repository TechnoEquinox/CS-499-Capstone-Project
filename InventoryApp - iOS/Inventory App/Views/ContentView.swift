//
//  ContentView.swift
//  Inventory App
//
//  Created by Connor Bailey on 11/14/25.
//

import SwiftUI

struct ContentView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var loginSuccess: Bool = false
    @State private var isCheckingServer: Bool = false
    @State private var connectionErrorMessage: String? = nil
    
    // Make a GET request to the /ping end-point to check for connectivity
    private func testConnectionAndNavigate() {
        // Reset state and show loading
        isCheckingServer = true
        connectionErrorMessage = nil
        
        Task {
            do {
                let ok = try await InventoryAPIClient.shared.ping()
                await MainActor.run {
                    isCheckingServer = false
                    if ok {
                        loginSuccess = true
                    } else {
                        connectionErrorMessage = "Unable to verify the server connection. Please try again."
                    }
                }
            } catch {
                await MainActor.run {
                    isCheckingServer = false
                    connectionErrorMessage = "Unable to reach server: \(error.localizedDescription)"
                }
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Full screen gray
                Color(.systemGray)
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Title at the top and subtitle
                    VStack(spacing: 4) {
                        Text("Inventory App")
                            .font(.largeTitle.bold())
                            .multilineTextAlignment(.center)
                        
                        Text("Project for CS: 499")
                            .font(.headline)
                            .italic()
                        
                        Text("Created by Connor Bailey")
                            .font(.subheadline)
                    }
                    
                    Spacer()
                    
                    // Card for login form
                    VStack(spacing: 16) {
                        // Username field
                        TextField("Username", text: $username)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .multilineTextAlignment(.center)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 12)
                            .background(Color(.lightGray))
                            .cornerRadius(8)
                        
                        // Password field
                        SecureField("Password", text: $password)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .multilineTextAlignment(.center)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 12)
                            .background(Color(.lightGray))
                            .cornerRadius(8)
                        
                        // Button row
                        HStack {
                            Button("Create Account") {
                                testConnectionAndNavigate()
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .buttonStyle(.bordered)
                            .disabled(isCheckingServer)
                            
                            Button("Log In") {
                                testConnectionAndNavigate()
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .buttonStyle(.borderedProminent)
                            .disabled(isCheckingServer)
                        }
                        
                        if isCheckingServer {
                            ProgressView("Checking server connection...")
                                .font(.footnote)
                        }
                        
                        if let message = connectionErrorMessage {
                            Text(message)
                                .font(.footnote)
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.center)
                                .padding(.top, 4)
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color(.systemGray5))
                    )
                    .shadow(radius: 4)
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding()
            }
            // Navigate to Inventory screen
            .navigationDestination(isPresented: $loginSuccess) {
                InventoryView()
            }
        }
    }
}

#Preview {
    ContentView()
}
