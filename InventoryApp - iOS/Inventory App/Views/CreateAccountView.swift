//
//  CreateAccountView.swift
//  Inventory App
//
//  Created by Connor Bailey on 12/12/25.
//

import SwiftUI

struct CreateAccountView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""

    @State private var isSubmitting: Bool = false
    @State private var errorMessage: String? = nil

    /// Called after successful account creation so ContentView can pre-fill username, etc.
    let onCreated: (String) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray)
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    VStack(spacing: 6) {
                        Text("Create Account")
                            .font(.largeTitle.bold())

                        Text("Make a new Inventory App user")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    VStack(spacing: 14) {
                        TextField("Username", text: $username)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .multilineTextAlignment(.center)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 12)
                            .background(Color(.lightGray))
                            .cornerRadius(8)

                        SecureField("Password", text: $password)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .multilineTextAlignment(.center)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 12)
                            .background(Color(.lightGray))
                            .cornerRadius(8)

                        SecureField("Confirm Password", text: $confirmPassword)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .multilineTextAlignment(.center)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 12)
                            .background(Color(.lightGray))
                            .cornerRadius(8)

                        if isSubmitting {
                            ProgressView("Creating account...")
                                .font(.footnote)
                        }

                        if let errorMessage {
                            Text(errorMessage)
                                .font(.footnote)
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.center)
                        }

                        Button("Create") {
                            createAccount()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .buttonStyle(.borderedProminent)
                        .disabled(isSubmitting)
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
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .disabled(isSubmitting)
                }
            }
        }
    }

    private func createAccount() {
        errorMessage = nil

        let trimmedUser = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPass = password.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedConfirm = confirmPassword.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedUser.isEmpty else {
            errorMessage = "Please enter a username."
            return
        }

        guard !trimmedPass.isEmpty else {
            errorMessage = "Please enter a password."
            return
        }

        guard trimmedPass == trimmedConfirm else {
            errorMessage = "Passwords do not match."
            return
        }

        isSubmitting = true

        Task {
            do {
                // Keep your current behavior: ping first, then register
                let ok = try await InventoryAPIClient.shared.ping()
                guard ok else {
                    await MainActor.run {
                        isSubmitting = false
                        errorMessage = "Unable to verify the server connection. Please try again."
                    }
                    return
                }

                try await InventoryAPIClient.shared.register(username: trimmedUser, password: trimmedPass)

                await MainActor.run {
                    isSubmitting = false
                    onCreated(trimmedUser)
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isSubmitting = false
                    errorMessage = "Create account failed: \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview {
    CreateAccountView { _ in }
}
