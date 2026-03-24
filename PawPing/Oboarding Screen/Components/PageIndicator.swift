//
//  PageIndicator.swift
//  PawPing
//
//  Created by Shailesh on 24/03/26.
//

import SwiftUI
struct PageIndicator: View {
    let total: Int          // Total number of pages
    let current: Int        // The index of the currently active page

    var body: some View {
        HStack(spacing: 7) {
            // We use Array(0..<total) to help the compiler identify the range clearly
            ForEach(Array(0..<total), id: \.self) { index in
                let isActive = index == current
                
                // Each dot is a Capsule that expands when active
                Capsule()
                    .fill(isActive
                          ? OnboardingLayout.primaryBlue
                          : OnboardingLayout.primaryBlue.opacity(0.25))
                    .frame(width: isActive ? 22 : 8, height: 8)
            }
        }
        // Animate the size and color changes when 'current' page updates
        .animation(.spring(response: 0.35, dampingFraction: 0.72), value: current)
    }
}
