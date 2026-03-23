//
//  ContentView.swift
//  PawPing
//

import SwiftUI

struct ContentView: View {

    @State private var activityStore = ActivityStore()
    @State private var careStore     = CareStore()
    @State private var vaccineStore  = VaccineStore()

    var body: some View {
        TabView {
            Tab("Activity", systemImage: "dog.fill") {
                ActivityView(store: activityStore)
            }

            Tab("Care", systemImage: "pawprint.fill") {
                CareView(store: careStore, profile: activityStore.dogProfile)
            }

            Tab("Vaccine", systemImage: "syringe.fill") {
                VaccineView(store: vaccineStore, profile: activityStore.dogProfile)
            }
        } // TabView
        .tint(.pawPrimary) // ✅ kept original
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}
