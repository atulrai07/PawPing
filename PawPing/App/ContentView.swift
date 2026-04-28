//
//  ContentView.swift
//  PawPing
//
//  Created by Atul on 19/01/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(PetStore.self) var petStore
    @Environment(MealStore.self) var mealStore
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            ActivityView()
                .tabItem {
                    Label("Activity", systemImage: selectedTab == 0 ? "dog.fill" : "dog")
                }
                .tag(0)

            HealthView()
                .tabItem {
                    Label("Vaccine", systemImage: selectedTab == 1 ? "syringe.fill" : "syringe")
                }
                .tag(1)

            CareTabView()
                .tabItem {
                    Label("Care", systemImage: selectedTab == 2 ? "cross.case.fill" : "cross.case")
                }
                .tag(2)

            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: selectedTab == 3 ? "person.fill" : "person")
            }
            .tag(3)
        }
        .tint(.pawPrimary)
    }
}

#Preview {
    ContentView()
        .environment(PetStore())
        .environment(ActivityStore())
        .environment(MealStore())
        .environment(HealthStore())
        .environment(SymptomStore())
        .environment(AuthStore())
        .environment(AppState())
}
