//
//  AuthStore.swift
//  PawPing
//

import Foundation
import SwiftUI
import Observation
import Supabase

/// `AuthStore` manages the user's authentication lifecycle with Supabase.
/// It handles login, signup, session persistence, and updates the global `AppState`.
@MainActor
@Observable
class AuthStore {
    // MARK: - Properties
    /// Global application state to be updated on auth changes
    var appState: AppState?
    /// Supabase client for authentication requests
    private let client = SupabaseConfig.client
    
    /// Handle for the authentication state change listener.
    /// Marked as nonisolated let so it can be safely accessed in deinit.
    nonisolated private let authTask: Task<Void, Never>
    
    // MARK: - Initialization
    init(appState: AppState? = nil) {
        self.appState = appState
        
        // Start the listener immediately and store the task
        // We capture weak self to avoid a retain cycle
        let client = SupabaseConfig.client
        self.authTask = Task { [weak appState] in
            for await (event, session) in client.auth.authStateChanges {
                print("🔐 Auth Event: \(event)")
                
                // Update state on the Main Actor
                await MainActor.run {
                    if let user = session?.user {
                        appState?.currentUserId = user.id.uuidString
                        appState?.isAuthenticated = true
                    } else {
                        appState?.isAuthenticated = false
                        appState?.currentUserId = ""
                        appState?.hasPets = false
                    }
                }
            }
        }
    }
    
    deinit {
        // Stop listening when the store is destroyed
        authTask.cancel()
    }
    
    // MARK: - Authentication Methods
    
    /// Authenticates an existing user with email and password
    func login(email: String, password: String) async throws {
        do {
            _ = try await client.auth.signIn(email: email, password: password)
        } catch {
            print("❌ Login error: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Registers a new user and sets their initial profile data
    func signup(name: String, email: String, password: String) async throws {
        do {
            _ = try await client.auth.signUp(
                email: email,
                password: password,
                data: ["full_name": .string(name)]
            )
        } catch {
            print("❌ Signup error: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Ends the current user session
    func logout() async {
        do {
            try await client.auth.signOut()
        } catch {
            print("❌ Logout error: \(error.localizedDescription)")
            // If the server call fails, we still clear local state via the listener
        }
    }
}
