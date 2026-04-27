//
//  AppState.swift
//  PawPing
//

import SwiftUI
import Observation

@MainActor
@Observable
class AppState {
    var isAuthenticated: Bool {
        didSet { UserDefaults.standard.set(isAuthenticated, forKey: "isAuthenticated") }
    }
    
    var hasPets: Bool {
        didSet { UserDefaults.standard.set(hasPets, forKey: "hasPets") }
    }
    
    var currentUserId: String {
        didSet { UserDefaults.standard.set(currentUserId, forKey: "currentUserId") }
    }
    
    init() {
        self.isAuthenticated = UserDefaults.standard.bool(forKey: "isAuthenticated")
        self.hasPets = UserDefaults.standard.bool(forKey: "hasPets")
        self.currentUserId = UserDefaults.standard.string(forKey: "currentUserId") ?? ""
    }
}
