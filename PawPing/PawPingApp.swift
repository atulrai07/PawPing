//
//  PawPingApp.swift
//  PawPing
//
//  Created by Atul on 19/01/26.
//

import SwiftUI

// @main tells Swift this is THE entry point of our app.
// Think of it like main() in other languages.
@main
struct PawPingApp: App {
    // MARK: - Stores (single source of truth for the whole app)
    @State private var petStore      = PetStore()
    @State private var activityStore = ActivityStore()
    @State private var careStore     = CareStore()
    @State private var vaccineStore  = VaccineStore()
    @State private var symptomStore  = SymptomStore()

    @StateObject private var appState: AppState
    @StateObject private var authStore: AuthStore

    init() {
        let state = AppState()
        self._appState = StateObject(wrappedValue: state)
        self._authStore = StateObject(wrappedValue: AuthStore(appState: state))
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if !appState.isAuthenticated {
                    AuthFlowView()
                } else if !appState.hasPets {
                    AddPetView { newPet in
                        petStore.addPet(newPet)
                        appState.hasPets = true
                    }
                } else {
                    ContentView()
                }
            }
            .environmentObject(appState)
            .environmentObject(authStore)
            .environment(petStore)
            .environment(activityStore)
            .environment(careStore)
            .environment(vaccineStore)
            .environment(symptomStore)
        }
    }
}
