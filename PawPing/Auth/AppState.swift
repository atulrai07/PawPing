//
//  AppState.swift
//  PawPing
//

import SwiftUI
import Combine

@MainActor
class AppState: ObservableObject {
    @Published var isAuthenticated: Bool {
        didSet { UserDefaults.standard.set(isAuthenticated, forKey: "isAuthenticated") }
    }
    
    @Published var hasPets: Bool {
        didSet { UserDefaults.standard.set(hasPets, forKey: "hasPets") }
    }
    
    @Published var currentUserId: String {
        didSet { UserDefaults.standard.set(currentUserId, forKey: "currentUserId") }
    }
    
    init() {
        self.isAuthenticated = UserDefaults.standard.bool(forKey: "isAuthenticated")
        self.hasPets = UserDefaults.standard.bool(forKey: "hasPets")
        self.currentUserId = UserDefaults.standard.string(forKey: "currentUserId") ?? ""
    }
}
