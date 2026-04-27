//
//  ContentView.swift
//  PawPing
//
//  Created by Atul on 19/01/26.
//

import SwiftUI

struct ContentView: View {

    var body: some View {
        TabView {
            Tab("Activity", systemImage: "dog.fill") {
                ActivityView()
            }

            Tab("Care", systemImage: "pawprint.fill") {
                CareView()
            }

            Tab("Vaccine", systemImage: "syringe.fill") {
                VaccineView()
            }

            Tab("Profile", systemImage: "person.fill") {
                NavigationStack {
                    ProfileView()
                }
            }
        }
        .tint(Color("baseColor"))
    }
}

#Preview {
    ContentView()
        .environment(PetStore())
        .environment(ActivityStore())
        .environment(CareStore())
        .environment(VaccineStore())
        .environment(SymptomStore())
}
