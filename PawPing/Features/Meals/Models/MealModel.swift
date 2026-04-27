//
//  MealModel.swift
//  PawPing
//
//  Created by Atul on 01/02/26.
//

import Foundation

// MARK: - Meals

struct Meal: Identifiable, Codable {
    let id: UUID
    var petId: UUID
    var icon: String
    var time: String
    var meridian: String
    var date: Date = Date()
    var mealType: MealType
    var foodType: FoodType?
    var quantity: Double = 1.0
    var unit: String = "cup"
    var calories: Double = 0
    var ingredients: [MealIngredient] = []
    var isTaken: Bool

    enum CodingKeys: String, CodingKey {
        case id, icon, time, meridian, date, quantity, unit, calories, ingredients
        case petId = "pet_id"
        case mealType = "meal_type"
        case foodType = "food_type"
        case isTaken = "is_taken"
    }
}

struct MealIngredient: Codable, Identifiable {
    var id = UUID()
    var name: String
    var quantity: Double
    var unit: String = "g"
    var caloriesPer100g: Double
    
    var calculatedCalories: Double {
        (caloriesPer100g / 100.0) * quantity
    }
}

struct USDAFood: Codable, Identifiable {
    var id: String { name }
    let name: String
    let caloriesPer100g: Double
}

enum MealType: String, Codable {
    case breakfast = "Breakfast"
    case lunch     = "Lunch"
    case dinner    = "Dinner"
}
