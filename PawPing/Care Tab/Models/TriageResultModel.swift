//
//  TriageResultModel.swift
//  PawPing
//
//  Created by Antigravity on 24/04/26.
//
//  The output model produced by SymptomStore.analyze().
//  Contains the overall severity, emergency flag, matched conditions, and advice.
//

import Foundation

// MARK: - Triage Result

struct TriageResult {
    let overallSeverity: ConditionSeverity
    let isEmergency: Bool
    let matchedConditions: [ConditionMatch]
    let recommendedAction: String
}

// MARK: - Condition Match

/// A single condition that matched the user's selected symptoms.
struct ConditionMatch: Identifiable {
    let id: String
    let condition: DogCondition
    let score: Double              // 0.0 – 1.0 (percentage of symptom weight matched)
    let matchedSymptomCount: Int   // how many of the condition's symptoms were selected

    /// Human-readable match percentage, e.g. "72%"
    var matchPercentageText: String {
        "\(Int(score * 100))%"
    }
}
