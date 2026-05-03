//
//  AuthService.swift
//  PawPing
//
//  Created by SidMoon on 27/04/26.
//  Description: A dedicated service for all Authentication operations in Supabase.
//  This handles login, signup, and session management.
//

import Foundation
import Supabase

class AuthService {
    // MARK: - Properties
    private let client = SupabaseConfig.client
    
    // MARK: - Public Methods
    
    /// Returns the current active session if one exists.
    func getCurrentSession() async throws -> Session {
        return try await client.auth.session
    }
    
    /// Logs in a user with email and password.
    func signIn(email: String, password: String) async throws -> Session {
        return try await client.auth.signIn(email: email, password: password)
    }
    
    /// Registers a new user with email, password, and metadata.
    func signUp(email: String, password: String, metadata: [String: AnyJSON]) async throws -> AuthResponse {
        return try await client.auth.signUp(
            email: email,
            password: password,
            data: metadata
        )
    }
    
    /// Signs out the current user.
    func signOut() async throws {
        try await client.auth.signOut()
    }
}
