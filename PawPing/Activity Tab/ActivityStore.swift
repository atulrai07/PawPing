//
//  ActivityStore.swift
//  PawPing
//
//  Created by SidMoon on 16/03/26.
//

import Foundation

@Observable
class ActivityStore {

    var dogProfile: DogProfile
    var meals: [Meal] = []
    var vaccines: [Vaccine] = []
    var allergies: [Allergy] = []
    var walkActivity: WalkActivity
    var timeWalkedGraph: TimeWalkedGraphModel

    init() {

        let sampleDogId = UUID()

        dogProfile = DogProfile(
            id: sampleDogId,
            ownerId: UUID(),
            dogName: "Buddy",
            breed: "Labrador",
            gender: .male,
            age: "2"
        )

        meals = [
            Meal(
                id: UUID(),
                dogId: sampleDogId,
                icon: "sun.max",
                time: "8:00",
                meridian: "AM",
                mealType: .breakfast,
                mealName: .dogFood,
                isTaken: true
            ),

            Meal(
                id: UUID(),
                dogId: sampleDogId,
                icon: "sunset.fill",
                time: "12:30",
                meridian: "PM",
                mealType: .lunch,
                mealName: .chickenAndRice,
                isTaken: false
            ),

            Meal(
                id: UUID(),
                dogId: sampleDogId,
                icon: "moon",
                time: "8:30",
                meridian: "PM",
                mealType: .dinner,
                mealName: .eggAndRice,
                isTaken: false
            )
        ]

        vaccines = [
            Vaccine(
                id: UUID(),
                dogId: sampleDogId,
                name: "Rabies Booster",
                givenDate: Date(),
                daysLeft: 3,
                frequency: 12,
                frequencyType: .monthly,
                vaccineNotes: "N/A"
            )
        ]

        allergies = [
            Allergy(
                id: UUID(),
                dogId: sampleDogId,
                allergyName: "Flea Dermatitis",
                allergyType: .environmental,
                allergyNotes: "N/A",
                allergen: "Gluten"
            ),

            Allergy(
                id: UUID(),
                dogId: sampleDogId,
                allergyName: "Flea Dermatitis",
                allergyType: .environmental,
                allergyNotes: "N/A",
                allergen: "Lactose"
            )
        ]

        walkActivity = WalkActivity(
            currentMinutes: 23,
            goalMinutes: 60
        )

        timeWalkedGraph = TimeWalkedGraphModel(
            data: [
                TimeWalkedData(day: "MON", minutes: 10),
                TimeWalkedData(day: "TUE", minutes: 28),
                TimeWalkedData(day: "WED", minutes: 18),
                TimeWalkedData(day: "THU", minutes: 42),
                TimeWalkedData(day: "FRI", minutes: 38),
                TimeWalkedData(day: "SAT", minutes: 0),
                TimeWalkedData(day: "SUN", minutes: 0)
            ],
            goalMinutes: 60
        )
    }
}
