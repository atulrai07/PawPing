//
//  ActivityStore.swift
//  PawPing
//
//  Created by SidMoon on 16/03/26.
//


//
//  ActivityStore.swift
//  PawPing
//
//  Created by Atul on 01/02/26.
//

import Foundation

@Observable
class ActivityStore {

    var dogProfile: DogProfile
    var meals: [Meals] = []
    var vaccines: [Vaccines] = []
    var allergies: [Allergy] = []
    var walkActivity: WalkActivity
    var timeWalkedGraph: TimeWalkedGraphModel

    init() {
        let sampleDogId = UUID()

        dogProfile = DogProfile(
            id: UUID(), ownerId: UUID(),
            dogName: "Buddy", breed: "Labrador",
            gender: "male", age: "2"
        )

        meals = [
            Meals(id: UUID(), dogId: sampleDogId, icon: "sun.max",     time: "8:00",  meridian: "AM", mealType: .breakFast, mealName: .dogFood,       isTaken: true),
            Meals(id: UUID(), dogId: sampleDogId, icon: "sunset.fill", time: "12:30", meridian: "PM", mealType: .lunch,     mealName: .chickenAndRice, isTaken: false),
            Meals(id: UUID(), dogId: sampleDogId, icon: "moon",        time: "8:30",  meridian: "PM", mealType: .dinner,    mealName: .eggAndRice,     isTaken: false)
        ]

        vaccines = [
            Vaccines(
                id: UUID(), dogId: sampleDogId,
                name: "Rabies Booster", givenDate: Date(),
                daysLeft: 3, frequency: 12,
                frequencyType: .monthly, vaccineNotes: "N/A"
            )
        ]

        allergies = [
            Allergy(id: UUID(), dogId: sampleDogId, allergyName: "Flea Dermatitis", alleryType: .environmental, alleryNotes: "N/A", allergen: "Gluten"),
            Allergy(id: UUID(), dogId: sampleDogId, allergyName: "Flea Dermatitis", alleryType: .environmental, alleryNotes: "N/A", allergen: "Lactose")
        ]

        walkActivity = WalkActivity(currentMinutes: 0, goalMinutes: 60)

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
