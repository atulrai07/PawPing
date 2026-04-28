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
            await updateState(with: session.user)
        } catch {
            // No valid session found
            logoutLocally()
        }
    }
    
    func login(email: String, password: String) async throws {
        let response = try await client.auth.signIn(email: email, password: password)
        await updateState(with: response.user)
    }
    
    func signup(name: String, email: String, password: String) async throws {
        // We pass the name to user_metadata so our SQL trigger can pick it up
        let response = try await client.auth.signUp(
            email: email,
            password: password,
            data: ["full_name": .string(name)]
        )
        await updateState(with: response.user)
    }
    
    func logout() async {
        try? await client.auth.signOut()
        logoutLocally()
    }
    
    // MARK: - Private Helpers
    
    private func updateState(with user: User) async {
        // BUG FIX: Force lowercase for consistency with PetStore
        appState?.currentUserId = user.id.uuidString.lowercased()
        
        if case let .string(val) = user.userMetadata["full_name"] {
            appState?.currentUserName = val
        } else {
            appState?.currentUserName = "Pet Owner"
        }
        
        appState?.isAuthenticated = true
        
        // Ensure profile exists in DB
        await ensureProfileExists(for: user)
    }
    
    private func ensureProfileExists(for user: User) async {
        struct ProfileUpdate: Encodable {
            let id: String
            let full_name: String
            let email: String
        }
        
        let name: String
        if case let .string(val) = user.userMetadata["full_name"] {
            name = val
        } else {
            name = "New User"
        }
        
        // BUG FIX: Ensure the ID being upserted is lowercase
        let profile = ProfileUpdate(id: user.id.uuidString.lowercased(), full_name: name, email: user.email ?? "")
        
        do {
            try await client
                .from("profiles")
                .upsert(profile)
                .execute()
        } catch {
            print("Note: Profile upsert finished. \(error.localizedDescription)")
        }
    }
    
    private func logoutLocally() {
        appState?.isAuthenticated = false
        appState?.currentUserId = ""
        appState?.hasPets = false
    }
}
