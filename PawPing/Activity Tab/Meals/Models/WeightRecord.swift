import Foundation
import SwiftUI

struct WeightRecord: Identifiable, Codable {
    let id: UUID
    let petId: UUID
    let date: Date
    let weightKg: Double
    let bodyCondition: BodyCondition
}

enum BodyCondition: String, Codable, CaseIterable {
    case underweight, ideal, overweight

    var label: String {
        switch self {
        case .underweight: return "Underweight"
        case .ideal:       return "Ideal"
        case .overweight:  return "Overweight"
        }
    }
    var color: Color {
        switch self {
        case .underweight: return .red
        case .ideal:       return .green
        case .overweight:  return .orange
        }
    }
}
