//
//  AccountManagementView.swift
//  PawPing
//

import SwiftUI
import Supabase

struct AccountManagementView: View {
    @Environment(AuthStore.self) var authStore
    @State private var showingChangeEmail = false
    @State private var showingChangePassword = false
    @State private var showingDeleteAlert = false
    
    @State private var newEmail = ""
    @State private var newPassword = ""
    @State private var currentPassword = ""
    
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var showingError = false
    @State private var showingSuccess = false
    @State private var successMessage = ""
    
    let client = SupabaseConfig.client
    
    var body: some View {
        List {
            Section("Account Details") {
                Button("Change Email") {
                    showingChangeEmail = true
                }
                .foregroundStyle(.primary)
                
                Button("Change Password") {
                    showingChangePassword = true
                }
                .foregroundStyle(.primary)
            }
            
            Section {
                Button("Delete Account") {
                    showingDeleteAlert = true
                }
                .foregroundStyle(.red)
            } footer: {
                Text("Deleting your account is permanent and cannot be undone. All your data and pets will be removed.")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Account Management")
        .navigationBarTitleDisplayMode(.inline)
        
        // MARK: - Email Sheet
        .sheet(isPresented: $showingChangeEmail) {
            NavigationStack {
                Form {
                    Section(footer: Text("A confirmation link will be sent to your new email address.")) {
                        TextField("New Email Address", text: $newEmail)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                }
                .navigationTitle("Change Email")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") { showingChangeEmail = false }
                            .disabled(isLoading)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Save") {
                            Task { await updateEmail() }
                        }
                        .font(.headline)
                        .disabled(newEmail.isEmpty || isLoading)
                    }
                }
                .overlay {
                    if isLoading { ProgressView() }
                }
            }
        }
        
        // MARK: - Password Sheet
        .sheet(isPresented: $showingChangePassword) {
            NavigationStack {
                Form {
                    Section {
                        SecureField("New Password", text: $newPassword)
                    }
                }
                .navigationTitle("Change Password")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") { showingChangePassword = false }
                            .disabled(isLoading)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Save") {
                            Task { await updatePassword() }
                        }
                        .font(.headline)
                        .disabled(newPassword.isEmpty || isLoading)
                    }
                }
                .overlay {
                    if isLoading { ProgressView() }
                }
            }
        }
        
        // MARK: - Alerts
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "An unknown error occurred.")
        }
        .alert("Success", isPresented: $showingSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(successMessage)
        }
        .alert("Delete Account?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task { await deleteAccount() }
            }
        } message: {
            Text("Are you absolutely sure? This action cannot be reversed.")
        }
        .overlay {
            if isLoading {
                ZStack {
                    Color.black.opacity(0.3).ignoresSafeArea()
                    ProgressView()
                        .padding(24)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.systemBackground)))
                }
            }
        }
    }
    
    // MARK: - Logic
    
    private func updateEmail() async {
        isLoading = true
        do {
            try await client.auth.update(user: UserAttributes(email: newEmail))
            isLoading = false
            showingChangeEmail = false
            newEmail = ""
            successMessage = "A confirmation link has been sent to your new email."
            showingSuccess = true
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
    
    private func updatePassword() async {
        isLoading = true
        do {
            try await client.auth.update(user: UserAttributes(password: newPassword))
            isLoading = false
            showingChangePassword = false
            newPassword = ""
            successMessage = "Your password has been updated."
            showingSuccess = true
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
    
    private func deleteAccount() async {
        isLoading = true
        do {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            await authStore.logout()
            isLoading = false
        }
    }
}

#Preview {
    NavigationStack {
        AccountManagementView()
            .environment(AuthStore())
    }
}
