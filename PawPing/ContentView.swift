//
//  ContentView.swift
//  PawPing
//
//  Created by SidMoon on 16/03/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(PetStore.self) var petStore
    @Environment(AppState.self) var appState
    
    var body: some View {
        @Bindable var store = petStore
        TabView {
            Tab("Home", systemImage: "house.fill") {
                ActivityView()
            }

            Tab("Vaccine", systemImage: "syringe.fill") {
                HealthView()
            }

            Tab("Find", systemImage: "magnifyingglass") {
                CareView()
            }

            Tab("Profile", systemImage: "person.fill") {
                NavigationStack {
                    ProfileView()
                }
            }
        }
        .tint(Color("baseColor"))
        .task {
            await petStore.fetchPets()
        }
        .alert("Error", isPresented: $store.showError) {
            Button("OK", role: .cancel) {
                store.lastError = nil
            }
        } message: {
            Text(store.lastError ?? "An unknown error occurred.")
        }
    }
}

#Preview {
    ContentView()
        .environment(PetStore())
        .environment(AppState())
        .environment(ActivityStore())
        .environment(HealthStore())
        .environment(CareStore())
        .environment(AuthStore())
        .environment(WeightStore())
        .environment(DietAssistantStore())
        .environment(MedicationStore())
}
