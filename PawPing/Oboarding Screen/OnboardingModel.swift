//
//  OnboardingModel.swift
//  PawPing
//
//  Created by Shailesh on 24/03/26.
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
        dogImage: "OnboardingDog 1",
        lineImage: "OnboardingLine 1"
    ),
    OnboardingItem(
        title: "Diet & Feeding\nTracker",
        description: "Track Meals and Allergies of Your Dog",
        dogImage: "OnboardingDog 2",
        lineImage: "OnboardingLine 2"
    ),
    OnboardingItem(
        title: "Never Miss a\nhealth Milestone",
        description: "Automatic Reminders for Vaccines",
        dogImage: "OnboardingDog 3",
        lineImage: "OnboardingLine 3"
    ),
    OnboardingItem(
        title: "Expert Care just a\nTap Away",
        description: "Connect Nearby Vet Care and Day Care\nfor Better Support",
        dogImage: "OnboardingDog 4",
        lineImage: "OnboardingLine 4"
    )
]
