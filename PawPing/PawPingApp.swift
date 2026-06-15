//
//  PawPingApp.swift
//  PawPing
//

import SwiftUI
import Supabase

@main
struct PawPingApp: App {
    @State private var petStore      = PetStore()
    @State private var activityStore = ActivityStore()
    @State private var careStore     = CareStore()
    @State private var healthStore   = HealthStore()
    @State private var weightStore   = WeightStore()
    @State private var dietAssistantStore = DietAssistantStore()
    @State private var medicationStore = MedicationStore()
    @State private var appState      = AppState()
    @State private var authStore: AuthStore?
    
    // Initial loading and splash
    @State private var isInitialLoading = true
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashView(showSplash: $showSplash)
                        .transition(.opacity)
                        .zIndex(10)
                }
                
                if let authStore {
                    Group {
                        if !appState.hasSeenOnboarding {
                            OnboardingView {
                                withAnimation {
                                    appState.hasSeenOnboarding = true
                                }
                            }
                        } else if isInitialLoading {
                            ProgressView("Syncing your data...")
                        } else if !appState.isAuthenticated {
                            AuthFlowView()
                        } else if !appState.hasPets {
                            AddPetView {
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
            .environment(healthStore)
            .environment(weightStore)
            .environment(dietAssistantStore)
            .environment(medicationStore)
            .task {
                if authStore == nil {
                    authStore = AuthStore(appState: appState)
                }
                
                if appState.isAuthenticated {
                    isInitialLoading = true
                    await petStore.fetchPets()
                    activityStore.switchPet(to: petStore.activePetId)
                    appState.hasPets = !petStore.pets.isEmpty
                    isInitialLoading = false
                } else {
                    isInitialLoading = false
                }
            }
            .task(id: appState.isAuthenticated) {
                if appState.isAuthenticated {
                    isInitialLoading = true
                    await petStore.fetchPets()
                    activityStore.switchPet(to: petStore.activePetId)
                    appState.hasPets = !petStore.pets.isEmpty
                    isInitialLoading = false
                }
            }
            }
            .onChange(of: petStore.activePetId) { _, newPetId in
                activityStore.switchPet(to: newPetId)
                
                if let newPetId {
                    Task {
                        await healthStore.fetchVaccines(for: newPetId)
                        await medicationStore.fetchMedications(for: newPetId)
                    }
                }
            }
        }
}
