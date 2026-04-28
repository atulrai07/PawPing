//
//  View+CareHelpers.swift
//  PawPing
//
//  Created by SidMoon on 28/04/26.
//

import SwiftUI

extension View {
    @ViewBuilder
    func loadingView(label: String) -> some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.pawBackground)
    }
    
    @ViewBuilder
    func emptyStateView(icon: String, message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundStyle(.secondary.opacity(0.4))
            
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.pawBackground)
    }
}
