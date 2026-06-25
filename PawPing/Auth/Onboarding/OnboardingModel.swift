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
        description: "Track daily walks and keep your dog active",
        dogImage: "dog1Onboarding",
        lineImage: "line1Onboarding"
    ),
    OnboardingItem(
        title: "Diet & Feeding\nTracker",
        description: "Track meals and allergies of your dog",
        dogImage: "dog2Onboarding",
        lineImage: "line2Onboarding"
    ),
    OnboardingItem(
        title: "Never Miss a\nHealth Milestone",
        description: "Get automatic reminders for vaccines",
        dogImage: "dog3Onboarding",
        lineImage: "line1Onboarding"
    ),
    OnboardingItem(
        title: "Expert Care Just a\nTap Away",
        description: "Connect with nearby vet care and daycare for better support",
        dogImage: "dog4Onboarding",
        lineImage: "line4Onboarding"
    )
]
