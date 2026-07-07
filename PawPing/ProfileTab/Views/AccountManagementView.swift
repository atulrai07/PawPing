//
//  AccountManagementView.swift
//  PawPing
//
//  Created by Atul on 25/03/26.
//

import SwiftUI

struct AccountManagementView: View {
    @Environment(AuthStore.self) var authStore
    @State private var showingDeleteAlert = false
    
    var body: some View {
        List {
            Section("Security") {
                Button("Change Password") {
                    // Navigate to change password flow
                }
                Button("Change Email") {
                    // Navigate to change email flow
                }
            }
            
            Section {
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    Text("Delete Account")
                }
            } footer: {
                Text("Deleting your account will permanently remove all your data, including pet profiles and health records.")
            }
        }
        .navigationTitle("Account Settings")
        .alert("Delete Account?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete Permanently", role: .destructive) {
                // Task { await authStore.deleteAccount() }
            }
        } message: {
            Text("This action cannot be undone. Are you absolutely sure?")
        }
    }
}
