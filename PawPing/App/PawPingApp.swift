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
    @State private var mealStore     = MealStore()
    @State private var healthStore   = HealthStore()
    @State private var dietAssistantStore = DietAssistantStore()
    @State private var weightStore   = WeightStore()
    @State private var appState      = AppState()
    @State private var authStore: AuthStore?

    var body: some Scene {
        WindowGroup {
            Group {
                if let authStore {
                    Group {
                        if !appState.isAuthenticated {
                            AuthFlowView()
                        } else if petStore.pets.isEmpty {
                            AddPetView { newPet in
                                let success = await petStore.addPet(newPet)
                                if success {
                                    appState.hasPets = true
                                }
                                return success
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
            .environment(mealStore)
            .environment(healthStore)
            .environment(dietAssistantStore)
            .environment(weightStore)
            .environment(authStore ?? AuthStore(appState: appState))
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
