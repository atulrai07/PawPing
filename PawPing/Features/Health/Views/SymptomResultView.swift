//
//  SymptomResultView.swift
//  PawPing
//
//  Created by Antigravity on 27/04/26.
//

import SwiftUI

struct SymptomResultView: View {
    @Environment(SymptomStore.self) var symptomStore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Illustration
                ZStack {
                    Circle()
                        .fill(severityColor.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: severityIcon)
                        .font(.system(size: 60))
                        .foregroundStyle(severityColor)
                }
                .padding(.top, 40)
                
                VStack(spacing: 8) {
                    Text(severityTitle)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Analysis Result")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                // Advice Card
                VStack(alignment: .leading, spacing: 16) {
                    Label("Recommended Action", systemImage: "info.circle.fill")
                        .font(.headline)
                        .foregroundStyle(severityColor)
                    
                    Text(symptomStore.advice)
                        .font(.body)
                        .lineSpacing(4)
                }
                .padding(20)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color("cardBackground")))
                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
                .padding(.horizontal)
                
                // Selected Symptoms List
                VStack(alignment: .leading, spacing: 12) {
                    Text("Symptoms Logged")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        let selected = symptomStore.categories.flatMap { $0.symptoms }.filter { symptomStore.selectedSymptoms.contains($0.id) }
                        ForEach(selected) { symptom in
                            HStack {
                                Text(symptom.name)
                                Spacer()
                                severityLabel(for: symptom.severity)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal)
                            if symptom.id != selected.last?.id {
                                Divider().padding(.leading)
                            }
                        }
                    }
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color("cardBackground")))
                    .padding(.horizontal)
                }
                
                Spacer(minLength: 40)
                
                Button {
                    dismiss()
                } label: {
                    Text("Back to Dashboard")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.pawPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .background(Color("baseBackground"))
        .navigationTitle("Result")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Helpers
    
    var severityColor: Color {
        switch symptomStore.currentSeverity {
        case .mild: return .green
        case .moderate: return .orange
        case .severe: return .red
        }
    }
    
    var severityIcon: String {
        switch symptomStore.currentSeverity {
        case .mild: return "checkmark.shield.fill"
        case .moderate: return "exclamationmark.shield.fill"
        case .severe: return "exclamationmark.octagon.fill"
        }
    }
    
    var severityTitle: String {
        switch symptomStore.currentSeverity {
        case .mild: return "Mild Symptoms"
        case .moderate: return "Moderate Concern"
        case .severe: return "Severe Condition"
        }
    }
    
    func severityLabel(for severity: SymptomStore.Severity) -> some View {
        Text(severityName(severity))
            .font(.caption2)
            .fontWeight(.bold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(severityColor(severity).opacity(0.1))
            .foregroundStyle(severityColor(severity))
            .clipShape(Capsule())
    }
    
    func severityName(_ severity: SymptomStore.Severity) -> String {
        switch severity {
        case .mild: return "MILD"
        case .moderate: return "MODERATE"
        case .severe: return "SEVERE"
        }
    }
    
    func severityColor(_ severity: SymptomStore.Severity) -> Color {
        switch severity {
        case .mild: return .green
        case .moderate: return .orange
        case .severe: return .red
        }
    }
}

#Preview {
    SymptomResultView()
        .environment(SymptomStore())
}
