//
//  ContentView.swift
//  PawPing
//
//  Created by Atul on 19/01/26.
//

import SwiftUI

struct ContentView: View {

    // MARK: - Stores (single source of truth for the whole app)
    @State private var activityStore = ActivityStore()
    @State private var careStore     = CareStore()
    @State private var vaccineStore  = VaccineStore()

    var body: some View {
        TabView {
            Tab("Activity", systemImage: "dog.fill") {
                ActivityView(store: activityStore)
            }

            Tab("Care", systemImage: "pawprint.fill") {
                CareView(store: careStore)
            }

            Tab("Vaccine", systemImage: "syringe.fill") {
                VaccineView(store: vaccineStore, profile: activityStore.dogProfile)
            }
        }
        .tint(Color("baseRed"))
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}
