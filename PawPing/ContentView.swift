//
//  ContentView.swift
//  PawPing
//
//  Created by Atul on 19/01/26.
//

import SwiftUI

struct ContentView: View {
    @State private var showSplash = true
    @State private var hasCompletedOnboarding = false

    // MARK: - Stores (single source of truth for the whole app)
    // @State here because ContentView OWNS these stores.
    // SwiftUI watches @State for changes and re-renders the UI automatically.
    // We pass them down to child views as plain values (not bindings),
    // because each store is an @Observable class — SwiftUI tracks its
    // properties for us without needing $ binding syntax.
    @State private var activityStore = ActivityStore()
    @State private var careStore     = CareStore()
    @State private var vaccineStore  = VaccineStore()

    var body: some View {
        if showSplash {
            SplashView(showSplash: $showSplash)
        } else if !hasCompletedOnboarding {
            OnboardingView(onCompletion: {
                withAnimation {
                    hasCompletedOnboarding = true
                }
            })
        } else {
            TabView {
                Tab("Activity", systemImage: "dog.fill") {
                    ActivityView(store: activityStore)
                }

                Tab("Care", systemImage: "pawprint.fill") {
                    // CareView also needs the dog profile (for the Home pin on the map),
                    // so we grab it from activityStore which owns the profile data.
                    CareView(store: careStore, profile: activityStore.dogProfile)
                }

                Tab("Vaccine", systemImage: "syringe.fill") {
                    VaccineView(store: vaccineStore, profile: activityStore.dogProfile)
                }
            } // TabView
            .tint(.pawPrimary) // brand-blue highlight for the active tab
        }
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}
