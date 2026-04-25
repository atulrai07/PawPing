//
//  FoodModel.swift
//  PawPing
//
//  Created by Atul on 25/04/26.
//
//  Structured food types and calorie data models for the Meals & Diet system.
//  FoodType replaces the old MealName enum with a cleaner, scalable structure.
//  FoodCalorieEntry maps to the bundled food_calories.json dataset.
//

import Foundation

// MARK: - Food Type

/// The structured food categories a user can pick when logging a meal.
/// Raw values match the keys in food_calories.json for direct lookup.
enum FoodType: String, CaseIterable, Identifiable, Codable {
    case dryDogFood   = "dry_dog_food"
    case wetDogFood   = "wet_dog_food"
    case chicken      = "chicken"
    case rice         = "rice"
    case egg          = "egg"
    case custom       = "custom"

    var id: String { rawValue }

    /// User-facing display name
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

    /// SF Symbol icon for the food type grid
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

    /// Whether this food type requires a manual calorie estimate
    var isEstimateOnly: Bool {
        self == .custom
    }

    /// Food types that have entries in the JSON dataset
    static var datasetTypes: [FoodType] {
        allCases.filter { !$0.isEstimateOnly }
    }
}

// MARK: - Food Calorie Entry (decoded from JSON)

/// Represents one row from food_calories.json.
/// Unit describes what one "serving" means (cup, 100g, unit),
/// calories is the kcal for that single unit.
struct FoodCalorieEntry: Codable {
    let unit: String
    let calories: Double
}

