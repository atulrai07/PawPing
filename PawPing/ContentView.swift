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
        TabView {
            Tab("Home", systemImage: "house.fill") {
                ActivityView()
            }

            Tab("Vaccines", systemImage: "syringe.fill") {
                HealthView()
            }

            Tab("Care", systemImage: "pet.carrier.fill") {
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
            // BUG FIX 2: Ensure data is fresh when entering ContentView.
            // We do NOT modify appState.hasPets here to prevent accidental "bounces"
            // if the network is slow. The App root handles the routing logic.
            await petStore.fetchPets()
        }
    }
}

#Preview {
    ContentView()
        .environment(PetStore())
        .environment(AppState())
}
