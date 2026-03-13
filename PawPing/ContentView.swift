//
//  ContentView.swift
//  PawPing
//
//  Created by Atul on 19/01/26.
//

import SwiftUI

struct ContentView: View {
    let sampleProfile = DogProfile(id: UUID(), ownerId: UUID(), dogName: "Buddy", breed: "Labrador", gender: "male", age: "2")
    let sampleActivity = WalkActivity(currentMinutes: 23, goalMinutes: 60)
    
    var body: some View {
        VStack {
            TabView {
                // 2. Pass the sample data to ActivityView
                Tab("Activity", systemImage: "dog.fill") {
                    ActivityView()
                }

                Tab("Care", systemImage: "pawprint.fill") {
                    CareView()
                }

                Tab("Vaccine", systemImage: "syringe.fill") {
                    Text("Vaccine View")
                }
            }
            .tint(Color("baseRed"))
        }
    }
}

#Preview {
    ContentView()
}
