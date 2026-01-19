//
//  ContentView.swift
//  PawPing
//
//  Created by Atul on 19/01/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            TabView {
                Tab("Activity", systemImage: "dog.fill") {
                    ActivityView()
                }

                Tab("Care", systemImage: "pawprint.fill") {
                    
                }

                Tab("Vaccine", systemImage: "syringe.fill") {

                }
            }
            .tint(.red)
        }
    }
}

#Preview {
    ContentView()
}
