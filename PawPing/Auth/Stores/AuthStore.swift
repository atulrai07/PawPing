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
            if !session.isExpired {
                await updateState(with: session.user)
            } else {
                logoutLocally()
            }
        } catch {
            // No valid session found
            logoutLocally()
        }
    }
    
    func login(email: String, password: String) async throws {
        let response = try await client.auth.signIn(email: email, password: password)
        await updateState(with: response.user)
    }
    
    func signup(name: String, email: String, password: String) async throws -> Bool {
        // We pass the name to user_metadata so our SQL trigger can pick it up
        let response = try await client.auth.signUp(
            email: email,
            password: password,
            data: ["full_name": .string(name)]
        )
        if response.session != nil {
            await updateState(with: response.user)
            return true
        } else {
            return false
        }
    }
    
    func sendOTP(email: String, purpose: String) async throws {
        struct OTPRequest: Encodable {
            let email: String
            let purpose: String
        }
        let payload = OTPRequest(email: email, purpose: purpose)
        do {
            _ = try await client.functions.invoke(
                "send-otp",
                options: FunctionInvokeOptions(body: payload)
            )
        } catch {
            throw handleFunctionsError(error)
        }
    }
    
    func verifyOTP(email: String, code: String, purpose: String) async throws {
        struct OTPVerify: Encodable {
            let email: String
            let code: String
            let purpose: String
        }
        let payload = OTPVerify(email: email, code: code, purpose: purpose)
        do {
            _ = try await client.functions.invoke(
                "verify-otp",
                options: FunctionInvokeOptions(body: payload)
            )
        } catch {
            throw handleFunctionsError(error)
        }
    }
    
    func resetPassword(email: String, code: String, newPassword: String) async throws {
        struct ResetPasswordPayload: Encodable {
            let email: String
            let code: String
            let new_password: String
        }
        let payload = ResetPasswordPayload(email: email, code: code, new_password: newPassword)
        do {
            _ = try await client.functions.invoke(
                "reset-password",
                options: FunctionInvokeOptions(body: payload)
            )
        } catch {
            throw handleFunctionsError(error)
        }
    }
    
    private func handleFunctionsError(_ error: Error) -> Error {
        if let functionsError = error as? FunctionsError {
            switch functionsError {
            case .httpError(let code, let data):
                struct ServerError: Decodable {
                    let error: String
                }
                if let decoded = try? JSONDecoder().decode(ServerError.self, from: data) {
                    return NSError(
                        domain: "AuthStore",
                        code: code,
                        userInfo: [NSLocalizedDescriptionKey: decoded.error]
                    )
                }
            default:
                break
            }
        }
        return error
    }
    
    func logout() async {
        try? await client.auth.signOut()
        await NotificationManager.shared.cancelAllReminders()
        logoutLocally()
    }
    
    // MARK: - Private Helpers
    
    private func updateState(with user: User) async {
        // Clear all existing reminders to ensure a clean slate for the newly logged-in user
        await NotificationManager.shared.cancelAllReminders()
        
        // BUG FIX: Force lowercase for consistency with PetStore
        appState?.currentUserId = user.id.uuidString.lowercased()
        
        if case let .string(val) = user.userMetadata["full_name"] {
            appState?.currentUserName = val
        } else {
            appState?.currentUserName = "Pet Owner"
        }
        
        // Ensure profile exists in DB first to prevent RLS/sync races during login transitions
        await ensureProfileExists(for: user)
        
        appState?.isAuthenticated = true
    }
    
    private func ensureProfileExists(for user: User) async {
        let userId = user.id.uuidString.lowercased()
        
        struct ProfileFetch: Decodable {
            let id: String
            let full_name: String?
        }
        
        var existingProfile: ProfileFetch? = nil
        do {
            let fetched: [ProfileFetch] = try await client
                .from("profiles")
                .select("id, full_name")
                .eq("id", value: userId)
                .execute()
                .value
            existingProfile = fetched.first
        } catch {
            print("Error checking existing profile: \(error.localizedDescription)")
        }
        
        var nameToUse: String? = nil
        
        // 1. If DB already has a valid name, prioritize it
        if let dbName = existingProfile?.full_name,
           !dbName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
           dbName != "New User",
           dbName != "Pet Owner" {
            nameToUse = dbName
        }
        
        // 2. Otherwise, check userMetadata
        if nameToUse == nil {
            if case let .string(val) = user.userMetadata["full_name"],
               !val.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
               val != "New User",
               val != "Pet Owner" {
                nameToUse = val
            }
        }
        
        // 3. Fallback
        let finalName = nameToUse ?? existingProfile?.full_name ?? "Pet Owner"
        
        // Update local AppState name
        appState?.currentUserName = finalName
        
        // 4. Only upsert if profile is missing or name changed
        if existingProfile == nil || existingProfile?.full_name != finalName {
            struct ProfileUpdate: Encodable {
                let id: String
                let full_name: String
            }
            let profile = ProfileUpdate(id: userId, full_name: finalName)
            
            do {
                try await client
                    .from("profiles")
                    .upsert(profile)
                    .execute()
            } catch {
                print("Note: Profile upsert finished. \(error.localizedDescription)")
            }
        }
    }
    
    func signInWithApple(idToken: String, fullName: String?) async throws {
        let response = try await client.auth.signInWithIdToken(
            credentials: .init(provider: .apple, idToken: idToken)
        )
        
        var user = response.user
        
        if let fullName, !fullName.isEmpty {
            // Update Supabase Auth user metadata so it is stored in raw_user_meta_data
            if let updatedUser = try? await client.auth.update(user: UserAttributes(data: ["full_name": .string(fullName)])) {
                user = updatedUser
            }
            
            // Also upsert directly to profiles table
            struct ProfileUpdate: Encodable {
                let id: String
                let full_name: String
            }
            let profile = ProfileUpdate(
                id: user.id.uuidString.lowercased(),
                full_name: fullName
            )
            _ = try? await client.from("profiles").upsert(profile).execute()
        }
        
        await updateState(with: user)
    }
    
    func updateProfileName(to newName: String) async throws {
        let session = try await client.auth.session
        let user = session.user
        let userId = user.id.uuidString.lowercased()
        
        // 1. Update Supabase Auth metadata
        _ = try await client.auth.update(
            user: UserAttributes(data: ["full_name": .string(newName)])
        )
        
        // 2. Update profiles table
        struct ProfileUpdate: Encodable {
            let id: String
            let full_name: String
        }
        let profile = ProfileUpdate(
            id: userId,
            full_name: newName
        )
        try await client
            .from("profiles")
            .upsert(profile)
            .execute()
        
        // 3. Update local state name
        appState?.currentUserName = newName
    }
    
    private func logoutLocally() {
        appState?.isAuthenticated = false
        appState?.currentUserId = ""
        appState?.hasPets = false
    }
}
