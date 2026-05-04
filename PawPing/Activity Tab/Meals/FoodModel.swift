//
//  FoodModel.swift
//  PawPing
//
//  Created by Atul on 25/04/26.
//
//

import Foundation

// MARK: - Food Type

enum FoodType: String, CaseIterable, Identifiable, Codable {
    case dryDogFood   = "dry_dog_food"
    case wetDogFood   = "wet_dog_food"
    case chicken      = "chicken"
    case rice         = "rice"
    case egg          = "egg"
    case custom       = "custom"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .dryDogFood: return "Dry Dog Food"
        case .wetDogFood: return "Wet Dog Food"
        case .chicken:    return "Chicken"
        case .rice:       return "Rice"
        case .egg:        return "Egg"
        case .custom:     return "Custom"
        }
    }

    var icon: String {
        switch self {
        case .dryDogFood: return "bag.fill"
        case .wetDogFood: return "takeoutbag.and.cup.and.straw.fill"
        case .chicken:    return "fork.knife"
        case .rice:       return "leaf.fill"
        case .egg:        return "oval.fill"
        case .custom:     return "square.and.pencil"
        }
    }

    var isEstimateOnly: Bool {
        self == .custom
    }

    static var datasetTypes: [FoodType] {
        allCases.filter { !$0.isEstimateOnly }
    }
}

// MARK: - Food Calorie Entry (decoded from JSON)

struct FoodCalorieEntry: Codable {
    let unit: String
    let calories: Double
}

