//
//  ConditionModel.swift
//  PawPing
//
//  Created by Antigravity on 24/04/26.
//
//  Codable models for dog conditions loaded from the JSON knowledge base.
//

import SwiftUI

// MARK: - Dog Condition (parsed from dog_conditions.json)

struct DogCondition: Codable, Identifiable {
    let id: String
    let name: String
    let symptoms: [WeightedSymptom]
    let severity: ConditionSeverity
    let advice: String
}

// MARK: - Weighted Symptom

struct WeightedSymptom: Codable {
    let name: String
    let weight: Double
}

// MARK: - Condition Severity

enum ConditionSeverity: String, Codable, Comparable {
    case mild     = "mild"
    case moderate = "moderate"
    case serious  = "serious"
    case critical = "critical"

    /// Display label shown to the user
    var label: String {
        switch self {
        case .mild:     return "Mild"
        case .moderate: return "Moderate"
        case .serious:  return "Serious"
        case .critical: return "Critical"
        }
    }

    /// Color for severity badges — uses the PawPing palette where appropriate
    var color: Color {
        switch self {
        case .mild:     return .green
        case .moderate: return .orange
        case .serious:  return Color(red: 0.9, green: 0.3, blue: 0.2)
        case .critical: return .red
        }
    }

    /// SF Symbol for the severity badge
    var icon: String {
        switch self {
        case .mild:     return "checkmark.circle.fill"
        case .moderate: return "exclamationmark.triangle.fill"
        case .serious:  return "exclamationmark.circle.fill"
        case .critical: return "xmark.octagon.fill"
        }
    }

    // Comparable — lets us pick the highest severity among matched conditions
    private var sortOrder: Int {
        switch self {
        case .mild:     return 0
        case .moderate: return 1
        case .serious:  return 2
        case .critical: return 3
        }
    }

    static func < (lhs: ConditionSeverity, rhs: ConditionSeverity) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }
}
