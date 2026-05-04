//
//  DietPlanModel.swift
//  PawPing
//
//  Created by Atul on 25/04/26.
//
//

import Foundation

// MARK: - Diet Goal

enum DietGoal: String, CaseIterable, Identifiable, Codable {
    case loseWeight = "Lose Weight"
    case maintain   = "Maintain"
    case gain       = "Gain Weight"

    var id: String { rawValue }

    var rerMultiplier: Double {
        switch self {
        case .loseWeight: return 0.8
        case .maintain:   return 1.0
        case .gain:       return 1.2
        }
    }

    var subtitle: String {
        switch self {
        case .loseWeight: return "Calorie deficit mode"
        case .maintain:   return "Balanced nutrition"
        case .gain:       return "Healthy weight gain"
        }
    }

    var icon: String {
        switch self {
        case .loseWeight: return "arrow.down.circle.fill"
        case .maintain:   return "equal.circle.fill"
        case .gain:       return "arrow.up.circle.fill"
        }
    }
}

// MARK: - Weight Unit

enum WeightUnit: String, CaseIterable, Identifiable {
    case kg  = "kg"
    case lbs = "lbs"

    var id: String { rawValue }

    func toKg(_ value: Double) -> Double {
        switch self {
        case .kg:  return value
        case .lbs: return value * 0.453592
        }
    }

    func fromKg(_ kg: Double) -> Double {
        switch self {
        case .kg:  return kg
        case .lbs: return kg / 0.453592
        }
    }
}

// MARK: - Diet Plan

struct DietPlan: Codable {
    var isActive: Bool = false
    var goal: DietGoal = .maintain
    var weightKg: Double = 25.0
    var dailyCalorieTarget: Double = 0
    var activityLevel: String = "Moderate"
    var lifeStage: String = "Adult"

    var rer: Double {
        70.0 * pow(weightKg, 0.75)
    }

    mutating func calculateTarget() {
        dailyCalorieTarget = rer * goal.rerMultiplier
    }
}
