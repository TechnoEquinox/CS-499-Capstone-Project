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
    @State private var isShowingCreateAccount: Bool = false
    
    // Log in via /auth/login (store the JWT in Keychain via InventoryAPIClient)
    private func loginAndNavigate() {
        // Reset state and show loading
        isCheckingServer = true
        connectionErrorMessage = nil
        
        let trimmedUser = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPass = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedUser.isEmpty else {
            connectionErrorMessage = "Please enter a username."
            isCheckingServer = false
            return
        }
        
        guard !trimmedPass.isEmpty else {
            connectionErrorMessage = "Please enter a password."
            isCheckingServer = false
            return
        }
        
        Task {
            do {
                // Quick connectivity check
                let ok = try await InventoryAPIClient.shared.ping()
                guard ok else {
                    await MainActor.run {
                        isCheckingServer = false
                        connectionErrorMessage = "Unable to verify the server connection. Please try again."
                    }
                    return
                }

                // Ping succeeded — now attempt login
                try await InventoryAPIClient.shared.login(username: trimmedUser, password: trimmedPass)

                await MainActor.run {
                    isCheckingServer = false
                    loginSuccess = true
                }
            } catch {
                await MainActor.run {
                    isCheckingServer = false
                    connectionErrorMessage = "Login failed: \(error.localizedDescription)"
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
                                connectionErrorMessage = nil
                                isShowingCreateAccount = true
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .buttonStyle(.bordered)
                            .disabled(isCheckingServer)
                            
                            Button("Log In") {
                                loginAndNavigate()
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .buttonStyle(.borderedProminent)
                            .disabled(isCheckingServer)
                        }
                        
                        if isCheckingServer {
                            ProgressView("Signing in...")
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
            .sheet(isPresented: $isShowingCreateAccount) {
                CreateAccountView { newUsername in
                    // Pre-fill username and prompt the user to log in
                    username = newUsername
                    password = ""
                    connectionErrorMessage = "Account created. Please log in with your new credentials."
                }
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
