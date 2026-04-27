//
//  AuthStore.swift
//  PawPing
//

import Foundation
import SwiftUI
import Combine

@MainActor
class AuthStore: ObservableObject {
    var appState: AppState?
    
    init(appState: AppState? = nil) {
        self.appState = appState
    }
    
    func login(email: String, password: String) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_500_000_000)
        
        // Simulate success and update state
        let mockUserId = UUID().uuidString
        appState?.currentUserId = mockUserId
        appState?.isAuthenticated = true
    }
    
    func signup(name: String, email: String, password: String) async throws {
        try await Task.sleep(nanoseconds: 1_500_000_000)
        
        let mockUserId = UUID().uuidString
        appState?.currentUserId = mockUserId
        appState?.isAuthenticated = true
    }
    
    func sendOTP(email: String) async throws {
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
    
    func verifyOTP(code: String) async throws {
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
    
    func logout() {
        appState?.isAuthenticated = false
        appState?.currentUserId = ""
        appState?.hasPets = false
    }
}
