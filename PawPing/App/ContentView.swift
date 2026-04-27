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
        Group {
            tabBarView
        }
        .environment(\.activeTab, $selectedTab)
    }
    
    private var tabBarView: some View {
        TabView(selection: $selectedTab) {
            ActivityView()
                .tabItem {
                    Label("Activity", systemImage: "dog.fill")
                }
                .tag(0)

            MealLogView(store: mealStore)
                .tabItem {
                    Label("Meals", systemImage: "fork.knife")
                }
                .tag(1)

            HealthView()
                .tabItem {
                    Label("Health", systemImage: "heart.text.square.fill")
                }
                .tag(2)

            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
            .tag(3)
        }
        .tint(.pawPrimary)
    }
}

// MARK: - Environment Key for Tab Selection
private struct ActiveTabKey: EnvironmentKey {
    static let defaultValue: Binding<Int> = .constant(0)
}

extension EnvironmentValues {
    var activeTab: Binding<Int> {
        get { self[ActiveTabKey.self] }
        set { self[ActiveTabKey.self] = newValue }
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
