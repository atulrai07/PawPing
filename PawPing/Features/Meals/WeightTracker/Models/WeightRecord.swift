//
//  WeightRecord.swift
//  PawPing
//

import Foundation

struct WeightRecord: Identifiable, Codable {
    let id: UUID
    let petId: UUID
    let date: Date
    let weightKg: Double
    let bodyCondition: BodyCondition

    var bodyConditionLabel: String { bodyCondition.label }
    var bodyConditionColor: String { bodyCondition.colorName }
}

enum BodyCondition: String, Codable, CaseIterable {
    case underweight = "underweight"
    case ideal       = "ideal"
    case overweight  = "overweight"

    var label: String {
        switch self {
        case .underweight: return "Underweight"
        case .ideal:       return "Ideal"
        case .overweight:  return "Overweight"
        }
    }

    var colorName: String {
        switch self {
        case .underweight: return "appRed"
        case .ideal:       return "appGreen"
        case .overweight:  return "appOrange"
        }
    }

    // Maps to internal BCS range for any future vet export
    var bcsRange: String {
        switch self {
        case .underweight: return "1–3"
        case .ideal:       return "4–5"
        case .overweight:  return "6–9"
        }
    }
}
