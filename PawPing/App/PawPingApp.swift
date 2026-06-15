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
    @State private var appState: AppState
    @State private var authStore: AuthStore

    init() {
        let state = AppState()
        self._appState = State(initialValue: state)
        self._authStore = State(initialValue: AuthStore(appState: state))
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if !appState.isAuthenticated {
                    AuthFlowView()
                } else if !appState.hasPets {
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
            .environment(appState)
            .environment(petStore)
            .environment(activityStore)
            .environment(mealStore)
            .environment(healthStore)
            .environment(dietAssistantStore)
            .environment(weightStore)
            .environment(authStore)
            .task(id: appState.isAuthenticated) {
                // Whenever authentication status changes to true, fetch pets
                if appState.isAuthenticated {
                    await petStore.fetchPets()
                    if !petStore.pets.isEmpty {
                        appState.hasPets = true
                    }
                }
            }
        }
    }
}
