//
//  SymptomStore.swift
//  PawPing
//
//  Created by Antigravity on 27/04/26.
//

import Foundation
import Observation

@Observable
class SymptomStore {
    var categories: [SymptomCategory] = SymptomCategory.defaultCategories
    var selectedSymptoms: Set<UUID> = []
    
    struct Symptom: Identifiable, Hashable {
        let id = UUID()
        let name: String
        let severity: Severity
    }
    
    enum Severity: Int {
        case mild = 1
        case moderate = 2
        case severe = 3
    }
    
    struct SymptomCategory: Identifiable {
        let id = UUID()
        let name: String
        let icon: String
        let symptoms: [Symptom]
        
        static let defaultCategories = [
            SymptomCategory(name: "Behavior", icon: "brain.head.profile", symptoms: [
                Symptom(name: "Lethargy", severity: .moderate),
                Symptom(name: "Aggression", severity: .moderate),
                Symptom(name: "Excessive Sleeping", severity: .mild),
                Symptom(name: "Disorientation", severity: .severe)
            ]),
            SymptomCategory(name: "Digestion", icon: "mouth.fill", symptoms: [
                Symptom(name: "Vomiting", severity: .moderate),
                Symptom(name: "Diarrhea", severity: .moderate),
                Symptom(name: "Loss of Appetite", severity: .mild),
                Symptom(name: "Blood in Stool", severity: .severe)
            ]),
            SymptomCategory(name: "Skin & Coat", icon: "sparkles", symptoms: [
                Symptom(name: "Excessive Itching", severity: .mild),
                Symptom(name: "Hair Loss", severity: .mild),
                Symptom(name: "Redness/Rashes", severity: .moderate),
                Symptom(name: "Lumps/Bumps", severity: .moderate)
            ]),
            SymptomCategory(name: "Breathing", icon: "wind", symptoms: [
                Symptom(name: "Coughing", severity: .moderate),
                Symptom(name: "Sneezing", severity: .mild),
                Symptom(name: "Shortness of Breath", severity: .severe),
                Symptom(name: "Wheezing", severity: .severe)
            ])
        ]
    }
    
    func reset() {
        selectedSymptoms = []
    }
    
    func toggleSymptom(_ id: UUID) {
        if selectedSymptoms.contains(id) {
            selectedSymptoms.remove(id)
        } else {
            selectedSymptoms.insert(id)
        }
    }
    
    var currentSeverity: Severity {
        let selected = categories.flatMap { $0.symptoms }.filter { selectedSymptoms.contains($0.id) }
        let maxSeverity = selected.map { $0.severity.rawValue }.max() ?? 1
        return Severity(rawValue: maxSeverity) ?? .mild
    }
    
    var advice: String {
        switch currentSeverity {
        case .mild:
            return "Monitor your pet closely for the next 24 hours. Ensure they stay hydrated and rested. If symptoms persist, consult a vet."
        case .moderate:
            return "We recommend scheduling a vet visit within the next 48 hours. These symptoms could indicate an underlying issue that needs attention."
        case .severe:
            return "URGENT: Please contact an emergency vet immediately. These symptoms are serious and require prompt medical intervention."
        }
    }
}
