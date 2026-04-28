//
//  SymptomStore.swift
//  PawPing
//
//  Created by Atul on 24/04/26.
//
//  The brain of the Symptom Checker feature.
//  Loads the JSON knowledge base, manages symptom selection state,
//  and runs the weighted-scoring + triage engine.
//

import Foundation
import Observation

@Observable
class SymptomStore {

    // MARK: - Published State

    /// Master list of selectable symptoms
    var allSymptoms: [Symptom] = Symptom.catalog

    /// User's current symptom selection
    var selectedSymptoms: Set<Symptom> = []

    /// Conditions loaded from the bundled JSON
    var conditions: [DogCondition] = []

    /// Latest analysis result — nil until the user taps "Analyze"
    var triageResult: TriageResult?

    // MARK: - Init

    init() {
        loadConditions()
    }

    // MARK: - Data Loading

    /// Reads dog_conditions.json from the app bundle and decodes it.
    func loadConditions() {
        guard let url = Bundle.main.url(forResource: "dog_conditions", withExtension: "json") else {
            print("[SymptomStore]  dog_conditions.json not found in bundle")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            conditions = try JSONDecoder().decode([DogCondition].self, from: data)
        } catch {
            print("[SymptomStore]  Failed to decode conditions: \(error)")
        }
    }

    // MARK: - Selection

    func toggleSymptom(_ symptom: Symptom) {
        if selectedSymptoms.contains(symptom) {
            selectedSymptoms.remove(symptom)
        } else {
            selectedSymptoms.insert(symptom)
        }
    }

    func isSelected(_ symptom: Symptom) -> Bool {
        selectedSymptoms.contains(symptom)
    }

    // MARK: - Scoring Engine

    /// Analyzes selected symptoms against the knowledge base.
    ///
    /// Algorithm:
    /// 1. Check for emergency symptoms → sets emergency flag
    /// 2. For each condition, calculate:
    ///    score = Σ(matched symptom weights) / Σ(all condition symptom weights)
    /// 3. Filter conditions with score > 0.25
    /// 4. Sort descending, take top 5
    /// 5. Determine overall severity (max of matched, or critical if emergency)
    /// 6. Generate recommended action text
    func analyze() {
        let selectedKeys = Set(selectedSymptoms.map { $0.id })

        // Step 1: Emergency check
        let hasEmergencySymptom = selectedSymptoms.contains { $0.isEmergency }

        // Step 2 & 3: Score each condition
        var matches: [ConditionMatch] = []

        for condition in conditions {
            let totalWeight = condition.symptoms.reduce(0.0) { $0 + $1.weight }
            guard totalWeight > 0 else { continue }

            var matchedWeight = 0.0
            var matchedCount = 0

            for symptom in condition.symptoms {
                if selectedKeys.contains(symptom.name) {
                    matchedWeight += symptom.weight
                    matchedCount += 1
                }
            }

            let score = matchedWeight / totalWeight

            // Only include if at least 20% match
            if score >= 0.20 {
                matches.append(ConditionMatch(
                    id: condition.id,
                    condition: condition,
                    score: score,
                    matchedSymptomCount: matchedCount
                ))
            }
        }

        // Step 4: Sort and limit
        matches.sort { $0.score > $1.score }
        let topMatches = Array(matches.prefix(5))

        // Step 5: Overall severity
        let maxSeverity = topMatches.map { $0.condition.severity }.max() ?? .mild
        let overallSeverity: ConditionSeverity = hasEmergencySymptom ? .critical : maxSeverity

        // Step 6: Recommended action
        let action = recommendedAction(for: overallSeverity, isEmergency: hasEmergencySymptom)

        triageResult = TriageResult(
            overallSeverity: overallSeverity,
            isEmergency: hasEmergencySymptom,
            matchedConditions: topMatches,
            recommendedAction: action
        )
    }

    // MARK: - Reset

    func reset() {
        selectedSymptoms.removeAll()
        triageResult = nil
    }

    // MARK: - Helpers

    /// Filters symptoms by category for the selection UI
    func symptoms(for category: SymptomCategory) -> [Symptom] {
        allSymptoms.filter { $0.category == category }
    }

    private func recommendedAction(for severity: ConditionSeverity, isEmergency: Bool) -> String {
        if isEmergency {
            return " Emergency symptoms detected. Please contact your nearest emergency vet or animal hospital immediately."
        }
        switch severity {
        case .critical:
            return "Seek immediate veterinary attention. These symptoms may indicate a serious condition."
        case .serious:
            return "Schedule a vet appointment as soon as possible. Monitor your dog closely for any worsening."
        case .moderate:
            return "A vet visit is recommended within the next few days. Keep track of symptoms and any changes."
        case .mild:
            return "Monitor your dog at home. If symptoms persist beyond 2–3 days or worsen, consult your vet."
        }
    }
}
