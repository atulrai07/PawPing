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
            Image(systemName: "dog.fill")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hey Bro this our Pawping repository")
            Text("This is the develop branch")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
