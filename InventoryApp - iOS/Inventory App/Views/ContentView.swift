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
                                // TODO: Create new account view to handle new accounts
                                // For now, just bypass login
                                loginSuccess = true
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .buttonStyle(.bordered)
                            
                            Button("Log In") {
                                // TODO: Validate user login against our users table in our db
                                loginSuccess = true
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .buttonStyle(.borderedProminent)
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
