//
//  DietPlanModel.swift
//  PawPing
//
//  Created by Atul on 25/04/26.
//
//  Data models for the Diet Plan feature.
//  Uses veterinary-standard RER (Resting Energy Requirement) formula
//  to calculate daily calorie targets based on weight and goal.
//

import Foundation

// MARK: - Diet Goal

/// The three diet objectives a user can choose from.
/// Each has a multiplier applied to the RER base.
enum DietGoal: String, CaseIterable, Identifiable, Codable {
    case loseWeight = "Lose Weight"
    case maintain   = "Maintain"
    case gain       = "Gain Weight"

    var id: String { rawValue }

    /// Multiplier applied to RER to get the daily calorie target
    var rerMultiplier: Double {
        switch self {
        case .loseWeight: return 0.8
        case .maintain:   return 1.0
        case .gain:       return 1.2
        }
    }

    /// Short description for the diet progress card
    var subtitle: String {
        switch self {
        case .loseWeight: return "Calorie deficit mode"
        case .maintain:   return "Balanced nutrition"
        case .gain:       return "Healthy weight gain"
        }
    }

    /// SF Symbol for the goal picker
    var icon: String {
        switch self {
        case .loseWeight: return "arrow.down.circle.fill"
        case .maintain:   return "equal.circle.fill"
        case .gain:       return "arrow.up.circle.fill"
        }
    }
}

// MARK: - Weight Unit

/// Supports both kg and lbs input in the Diet Setup sheet.
/// All internal calculations use kg — lbs are converted before storage.
enum WeightUnit: String, CaseIterable, Identifiable {
    case kg  = "kg"
    case lbs = "lbs"

    var id: String { rawValue }

    /// Converts a value in this unit to kilograms
    func toKg(_ value: Double) -> Double {
        switch self {
        case .kg:  return value
        case .lbs: return value * 0.453592
        }
    }

    /// Converts a kg value to this unit for display
    func fromKg(_ kg: Double) -> Double {
        switch self {
        case .kg:  return kg
        case .lbs: return kg / 0.453592
        }
    }
}

// MARK: - Diet Plan

/// Holds the active diet plan configuration and calculated target.
/// Persisted via UserDefaults through MealDietStore.
struct DietPlan: Codable {
    var isActive: Bool = false
    var goal: DietGoal = .maintain
    var weightKg: Double = 25.0
    var dailyCalorieTarget: Double = 0
    var activityLevel: String = "Moderate"
    var lifeStage: String = "Adult"

    /// Resting Energy Requirement: 70 × (weight in kg)^0.75
    var rer: Double {
        70.0 * pow(weightKg, 0.75)
    }

    /// Calculates and stores the daily calorie target based on RER × goal multiplier
    mutating func calculateTarget() {
        dailyCalorieTarget = rer * goal.rerMultiplier
    }
}
