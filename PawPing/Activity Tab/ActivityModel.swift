//
//  ActivityModel.swift
//  PawPing
//
//  Created by Atul on 01/02/26.
//

import Foundation
import CoreLocation

// MARK: - User & Pet

struct Owner: Identifiable {
    let id: UUID
    var name: String
    var email: String
    var phone: String?
    var profileImage: String?
}

struct DogProfile: Identifiable {
    let id: UUID
    var ownerId: UUID
    var dogName: String
    var breed: String
    var gender: String
    var age: String
    var dogImage: String = "profilePhoto"
    
    static let sampleProfile = DogProfile(
        id: UUID(),
        ownerId: UUID(),
        dogName: "Buddy",
        breed: "Labrador",
        gender: "male",
        age: "2"
    )
}

// MARK: - Activity

struct Activity: Identifiable {
    let id: UUID
    var dogId: UUID
    var date: Date
    var currentMinutes: Int
    var goalMinutes: Int
    var distanceWalked: Double
    var goalDistanceWalked: Double
    
    var progress: Double {
        guard goalMinutes > 0 else { return 0 }
        return Double(currentMinutes) / Double(goalMinutes)
    }
}

struct WalkActivity {
    var currentMinutes: Int
    var goalMinutes: Int

    var progress: Double {
        guard goalMinutes > 0 else { return 0 }
        return Double(currentMinutes) / Double(goalMinutes)
    }
}

struct TimeWalkedData: Identifiable {
    let id = UUID()
    let day: String
    let minutes: Int
}

struct TimeWalkedGraphModel {
    let data: [TimeWalkedData]
    let goalMinutes: Int

    static let sample = TimeWalkedGraphModel(
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

    var maxMinutes: Int {
        max(goalMinutes, data.map { $0.minutes }.max() ?? 1)
    }
}

// MARK: - Meals

struct Meals: Identifiable {
    let id: UUID
    var dogId: UUID
    var icon: String
    var time: String
    var meridian: String
    var date: Date = Date()
    var mealType: MealType
    var mealName: MealName
    var isTaken: Bool
    
    static let sampleMeals: [Meals] = [
        Meals(id: UUID(), dogId: UUID(), icon: "sun.max", time: "8:00", meridian: "AM", mealType: .breakFast, mealName: .dogFood, isTaken: true),
        Meals(id: UUID(), dogId: UUID(), icon: "sunset.fill", time: "12:30", meridian: "PM", mealType: .lunch, mealName: .chickenAndRice, isTaken: false),
        Meals(id: UUID(), dogId: UUID(), icon: "moon", time: "8:30", meridian: "PM", mealType: .dinner, mealName: .eggAndRice, isTaken: false)
    ]
}

enum MealType: String {
    case breakFast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
}

enum MealName: String {
    case eggAndCheese = "Egg and Cheese"
    case eggAndRice = "Egg and Rice"
    case chickenAndRice = "Chicken and Rice"
    case curdAndRice = "Curd and Rice"
    case dogFood = "Dog Food"
    case dogFoodWithCarrots = "Dog Food with Carrots"
    case others = "Others"
}

// MARK: - Vaccines

struct Vaccines: Identifiable {
    let id: UUID
    var dogId: UUID
    var name: String
    var givenDate: Date?
    var daysLeft: Int
    var frequency: Int
    var frequencyType: VaccineFrequencyType
    var vaccineNotes: String
    
    static let sampleVaccines = Vaccines(
        id: UUID(),
        dogId: UUID(),
        name: "Rabies Booster",
        givenDate: Date(),
        daysLeft: 3,
        frequency: 12,
        frequencyType: .monthly,
        vaccineNotes: "N/A"
    )
}

enum VaccineFrequencyType: String {
    case days = "Days"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
}

// MARK: - Allergies

struct Allergy: Identifiable {
    let id: UUID
    var dogId: UUID
    var allergyName: String
    var alleryType: AllergyType
    var alleryNotes: String
    var allergen: String?
    
    static let sampleAllergies: [Allergy] = [
        Allergy(id: UUID(), dogId: UUID(), allergyName: "Flea Dermatitis", alleryType: .environmental, alleryNotes: "N/A", allergen: "Gluten"),
        Allergy(id: UUID(), dogId: UUID(), allergyName: "Flea Dermatitis", alleryType: .environmental, alleryNotes: "N/A", allergen: "Lactose")
    ]
}

enum AllergyType: String {
    case food = "Food"
    case medication = "Medication"
    case environmental = "Environmental"
}
