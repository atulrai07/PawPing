//
//  OnboardingView.swift
//  PawPing
//
//  Created by Shailesh on 24/03/26.
//

import SwiftUI

/// The main entry point for the onboarding flow.
/// It manages the current page state and handles user ̦̦gestures.
struct OnboardingView: View {
    var onCompletion: () -> Void
    
    // Tracks the current page index (0, 1, 2, or 3)
    @State private var currentPage = 0
    
    // The data source for onboarding items
    let items = onboardingData

    var body: some View {
        // We use a single PageView as a shell to keep animations smooth
        OnboardingPageView(
            currentPage: $currentPage,
            items: items,
            onGetStarted: {
                // Navigate to the main part of the app
                onCompletion()
            }
        )
        // Background color ensures the screen is never empty during shifts
        .background(OnboardingLayout.backgroundColor)
        
        // Custom Drag Gesture to allow manual swiping between pages
        .gesture(
            DragGesture()
                .onEnded { value in
                    let threshold: CGFloat = 50
                    if value.translation.width < -threshold {
                        // Swiped Left -> Go to next page
                        if currentPage < items.count - 1 {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                currentPage += 1
                            }
                        }
                    } else if value.translation.width > threshold {
                        // Swiped Right -> Go to previous page
                        if currentPage > 0 {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                currentPage -= 1
                            }
                        }
                    }
                }
        )
    }
}

// Preview provider for Xcode Canvas
#Preview {
    OnboardingView(onCompletion: {})
}

