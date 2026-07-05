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
    @State private var walkCardImageStore = WalkCardImageStore()
    @State private var appState      = AppState()
    @State private var authStore: AuthStore?
    
    // Initial loading and splash
    @State private var isInitialLoading = true
    @State private var showSplash = true
    @State private var showingNamePrompt = false

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
                    .sheet(isPresented: $showingNamePrompt) {
                        NamePromptSheet()
                            .environment(authStore)
                            .environment(petStore)
                    }
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
            .environment(walkCardImageStore)
            .task {
                if authStore == nil {
                    authStore = AuthStore(appState: appState)
                }
                
                if appState.isAuthenticated {
                    isInitialLoading = true
                    await petStore.fetchPets()
                    activityStore.switchPet(to: petStore.activePet)
                    healthStore.activePetId = petStore.activePetId
                    appState.hasPets = !petStore.pets.isEmpty
                    isInitialLoading = false
                } else {
                    isInitialLoading = false
                }
                checkNamePrompt()
            }
            .task(id: appState.isAuthenticated) {
                if appState.isAuthenticated {
                    isInitialLoading = true
                    await petStore.fetchPets()
                    activityStore.switchPet(to: petStore.activePet)
                    healthStore.activePetId = petStore.activePetId
                    appState.hasPets = !petStore.pets.isEmpty
                    isInitialLoading = false
                } else {
                    activityStore.switchPet(to: nil)
                    petStore.clear()
                    isInitialLoading = false
                }
                checkNamePrompt()
            }
            .onChange(of: appState.isAuthenticated) { _, _ in
                checkNamePrompt()
            }
            .onChange(of: appState.currentUserName) { _, _ in
                checkNamePrompt()
            }
            .onChange(of: isInitialLoading) { _, _ in
                checkNamePrompt()
            }
            .onChange(of: petStore.activePetId) { _, newPetId in
                let pet = petStore.pets.first { $0.id == newPetId }
                activityStore.switchPet(to: pet)
                healthStore.activePetName = pet?.name ?? ""
                healthStore.activePetId = newPetId
                
                if let newPetId {
                    Task {
                        await healthStore.fetchVaccines(for: newPetId)
                        await medicationStore.fetchMedications(for: newPetId)
                    }
                }
            }
        }
    }
    
    private func checkNamePrompt() {
        let name = appState.currentUserName.trimmingCharacters(in: .whitespacesAndNewlines)
        let isPlaceholder = name.isEmpty || name == "New User" || name == "Pet Owner"
        showingNamePrompt = appState.isAuthenticated && !isInitialLoading && isPlaceholder
    }
}
