//
//  OnboardingModel.swift
//  PawPing
//
//  Created by Shailesh on 24/03/26.
//  Updated by Atul on 28/04/26.
//

import Foundation

/// Defines the structure for each onboarding slide
struct OnboardingItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let dogImage: String
    let lineImage: String
}

/// The source of truth for all onboarding screen content
let onboardingData: [OnboardingItem] = [
    OnboardingItem(
        title: "Healthy & Active\nLifestyle",
        description: "Track daily walks and keep your dog\nactive",
        dogImage: "dog1Onboarding",
        lineImage: "line1Onboarding"
    ),
    OnboardingItem(
        title: "Diet & Feeding\nTracker",
        description: "Track Meals and Allergies of Your Dog",
        dogImage: "dog2Onboarding",
        lineImage: "line2Onboarding"
    ),
    OnboardingItem(
        title: "Never Miss a\nHealth Milestone",
        description: "Automatic Reminders for Vaccines",
        dogImage: "dog3Onboarding",
        lineImage: "" // line3 is missing in assets
    ),
    OnboardingItem(
        title: "Expert Care Just a\nTap Away",
        description: "Connect Nearby Vet Care and Day Care\nfor Better Support",
        dogImage: "dog4Onboarding",
        lineImage: "line4Onboarding"
    )
]
