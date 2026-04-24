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
    @State private var activityStore = ActivityStore()
    @State private var careStore     = CareStore()
    @State private var vaccineStore  = VaccineStore()
    @State private var symptomStore  = SymptomStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(activityStore)
                .environment(careStore)
                .environment(vaccineStore)
                .environment(symptomStore)
        }
    }
}
