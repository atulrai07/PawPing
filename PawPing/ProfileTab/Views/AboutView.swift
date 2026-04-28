//
//  AboutView.swift
//  PawPing
//
//  Created by Atul on 25/03/26.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image("Pawping_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                
                Text("PawPing")
                    .font(.largeTitle)
                    .bold()
                
                Text("Version 1.0.0")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text("PawPing is your ultimate companion for pet care. We help you track walks, manage health records, and keep your furry friends happy and healthy.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Divider().padding(.horizontal, 80)
                
                VStack(spacing: 8) {
                    Text("Developed by")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Team PawPing")
                        .font(.headline)
                }
            }
            .padding(.top, 40)
        }
        .navigationTitle("About Us")
        .navigationBarTitleDisplayMode(.inline)
    }
}
