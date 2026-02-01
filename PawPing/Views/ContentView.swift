
//
//  ContentView.swift
//  PawPing
//
//  Created by Atul on 19/01/26.
//

import SwiftUI

struct ContentView: View {
    // 1. Create the sample data here so it can be passed to the view
    let sampleProfile = Profile(dogName: "Buddy", breed: "Labrador", gender: "M", age: "2")
    let sampleActivity = WalkActivity(currentMinutes: 23, goalMinutes: 60)
    
    var body: some View {
        VStack {
            TabView {
                // 2. Pass the sample data to ActivityView
                Tab("Activity", systemImage: "dog.fill") {
                    ActivityView()
                }

                Tab("Care", systemImage: "pawprint.fill") {
                    Text("Care View") // Placeholder
                }

                Tab("Vaccine", systemImage: "syringe.fill") {
                    Text("Vaccine View") // Placeholder
                }
            }
            .tint(Color("baseRed")) // Make sure this matches your asset color
        }
    }
}

#Preview {
    ContentView()
}
