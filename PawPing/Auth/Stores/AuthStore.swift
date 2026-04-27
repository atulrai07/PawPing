//
//  AuthStore.swift
//  PawPing
//

import Foundation
import SwiftUI
import Observation
import Supabase

@MainActor
@Observable
class AuthStore {
    var appState: AppState?
    private let client = SupabaseConfig.client
    
    init(appState: AppState? = nil) {
        self.appState = appState
        
        // Check for existing session on startup
        Task {
            await checkSession()
        }
    }
    
    /// Checks if a user is already logged in
    func checkSession() async {
        do {
            let session = try await client.auth.session
            updateState(with: session.user)
        } catch {
            // No valid session found
            logoutLocally()
        }
    }
    
    func login(email: String, password: String) async throws {
        let response = try await client.auth.signIn(email: email, password: password)
        updateState(with: response.user)
    }
    
    func signup(name: String, email: String, password: String) async throws {
        // We pass the name to user_metadata so our SQL trigger can pick it up
        let response = try await client.auth.signUp(
            email: email,
            password: password,
            data: ["full_name": .string(name)]
        )
        updateState(with: response.user)
    }
    
    func logout() async {
        try? await client.auth.signOut()
        logoutLocally()
    }
    
    // MARK: - Private Helpers
    
    private func updateState(with user: User) {
        appState?.currentUserId = user.id.uuidString
        appState?.isAuthenticated = true
    }
    
    private func logoutLocally() {
        appState?.isAuthenticated = false
        appState?.currentUserId = ""
        appState?.hasPets = false
    }
}
