//
//  PawPingApp.swift
//  PawPing
//

import SwiftUI
import Supabase

@main
struct PawPingApp: App {
    // Stores
    @State private var petStore      = PetStore()
    @State private var activityStore = ActivityStore()
    @State private var careStore     = CareStore()
    @State private var vaccineStore  = VaccineStore()
    @State private var symptomStore  = SymptomStore()
    @State private var appState      = AppState()
    @State private var authStore: AuthStore?
    
    // BUG FIX 2: Prevent premature routing by adding a loading state
    @State private var isInitialLoading = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                if let authStore {
                    Group {
                        if isInitialLoading {
                            // Show loading while we verify pets in Supabase
                            ProgressView("Syncing your data...")
                        } else if !appState.isAuthenticated {
                            AuthFlowView()
                        } else if !appState.hasPets {
                            AddPetView {
                                // Once a pet is created, update state to unlock app
                                appState.hasPets = true
                            }
                        } else {
                            ContentView()
                        }
                    }
                    .environment(authStore)
                } else {
                    ProgressView("Connecting...")
                }
            }
            .environment(appState)
            .environment(petStore)
            .environment(activityStore)
            .environment(careStore)
            .environment(vaccineStore)
            .environment(symptomStore)
            .task {
                // Initialize authStore with appState reference
                if authStore == nil {
                    authStore = AuthStore(appState: appState)
                }
                
                // Initial check if already logged in from previous session
                if appState.isAuthenticated {
                    isInitialLoading = true
                    await petStore.fetchPets()
                    appState.hasPets = !petStore.pets.isEmpty
                    isInitialLoading = false
                } else {
                    isInitialLoading = false
                }
            }
            .task(id: appState.isAuthenticated) {
                // Whenever authentication status changes (e.g. user logs in)
                if appState.isAuthenticated {
                    isInitialLoading = true
                    await petStore.fetchPets()
                    appState.hasPets = !petStore.pets.isEmpty
                    isInitialLoading = false
                }
            }
            }
            .onChange(of: petStore.activePetId) { _, newPetId in
                // Sync the active pet ID into the specialized stores
                activityStore.switchPet(to: newPetId)
                
                if let newPetId {
                    Task {
                        await vaccineStore.fetchRecords(for: newPetId)
                    }
                }
            }
        }
}
