import Foundation

struct OnboardingItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let dogImage: String
    let lineImage: String
}

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
        title: "Never Miss a\nhealth Milestone",
        description: "Automatic Reminders for Vaccines",
        dogImage: "dog3Onboarding",
        lineImage: "line1Onboarding"
    ),
    OnboardingItem(
        title: "Expert Care just a\nTap Away",
        description: "Connect Nearby Vet Care and Day Care\nfor Better Support",
        dogImage: "dog4Onboarding",
        lineImage: "line4Onboarding"
    )
]
