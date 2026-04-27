//
//  PawPingApp.swift
//  PawPing
//

import SwiftUI

@main
struct PawPingApp: App {
    // MARK: - Stores
    @State private var petStore      = PetStore()
    @State private var activityStore = ActivityStore()
    @State private var careStore     = CareStore()
    @State private var vaccineStore  = VaccineStore()
    @State private var symptomStore  = SymptomStore()
    @State private var appState      = AppState()
    @State private var authStore: AuthStore?

    var body: some Scene {
        WindowGroup {
            Group {
                if let authStore {
                    Group {
                        if !appState.isAuthenticated {
                            AuthFlowView()
                        } else if !appState.hasPets {
                            AddPetView { newPet in
                                Task {
                                    await petStore.addPet(newPet)
                                    appState.hasPets = !petStore.pets.isEmpty
                                }
                            }
                        } else {
                            ContentView()
                        }
                    }
                    .environment(authStore)
                } else {
                    ProgressView("Loading...")
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
            }
            .task(id: appState.isAuthenticated) {
                // Whenever authentication status changes to true, fetch pets
                if appState.isAuthenticated {
                    await petStore.fetchPets()
                    appState.hasPets = !petStore.pets.isEmpty
                }
            }
        }
    }
}
