//
//  PrimaryButton.swift
//  PawPing
//
//  Created by Shailesh on 24/03/26.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    // Capsule-shaped background with the primary brand color
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(OnboardingLayout.primaryBlue)
                )
        }
        .buttonStyle(.plain) // Removes default blue highlighting
        .padding(.horizontal, 24)
    }
}

