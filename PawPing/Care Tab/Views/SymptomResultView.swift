//
//  SymptomResultView.swift
//  PawPing
//
//  Created by Antigravity on 24/04/26.
//
//  Displays the triage analysis results with severity, possible causes,
//  recommended actions, and an emergency CTA when needed.
//

import SwiftUI
import MapKit

struct SymptomResultView: View {
    @Environment(SymptomStore.self) var store
    @Environment(PetStore.self) var petStore
    @Environment(\.dismiss) var dismiss

    @State private var vetManager = VetSearchManager()
    @State private var showEmergencyHelp = false

    var body: some View {
        ScrollView {
            if let result = store.triageResult {
                VStack(spacing: 20) {

                    // MARK: - Severity Header
                    severityHeader(result)

                    // MARK: - Emergency CTA
                    if result.isEmergency {
                        emergencyCTA
                    }

                    // MARK: - Recommended Action
                    actionCard(result)

                    // MARK: - Possible Causes
                    if !result.matchedConditions.isEmpty {
                        possibleCausesSection(result)
                    }

                    // MARK: - Disclaimer
                    disclaimerSection

                    // MARK: - Check Again
                    checkAgainButton

                    // MARK: - Nearby Vets (Show for non-mild conditions)
                    if result.overallSeverity != .mild && !vetManager.nearbyVets.isEmpty {
                        nearbyVetsSection
                    }
                }
                .padding(.bottom, 40)
            } else {
                // Fallback — should not normally appear
                ContentUnavailableView(
                    "No Results",
                    systemImage: "doc.questionmark",
                    description: Text("Try selecting symptoms and analyzing again.")
                )
            }
        }
        .navigationTitle("Results")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showEmergencyHelp) {
            EmergencyHelpView()
        }
        .onAppear {
            if let result = store.triageResult, result.overallSeverity != .mild {
                let coords = CLLocationCoordinate2D(
                    latitude: petStore.activePet?.homeLatitude ?? 28.4210,
                    longitude: petStore.activePet?.homeLongitude ?? 77.5340
                )
                vetManager.searchNearbyVets(near: coords)
            }
        }
    }

    // MARK: - Subviews

    private func severityHeader(_ result: TriageResult) -> some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(result.overallSeverity.color.opacity(0.15))
                    .frame(width: 80, height: 80)

                Image(systemName: result.overallSeverity.icon)
                    .font(.system(size: 36))
                    .foregroundStyle(result.overallSeverity.color)
            }

            SeverityBadgeView(severity: result.overallSeverity, isLarge: true)

            Text(result.isEmergency ? "Emergency Detected" : "Assessment Complete")
                .font(.system(size: 14))
                .foregroundStyle(Color("secondaryText"))

            if result.matchedConditions.isEmpty {
                Text("No specific conditions strongly match these symptoms, but keep monitoring.")
                    .font(.system(size: 13))
                    .foregroundStyle(Color("secondaryText"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color("cardBackground"))
        )
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private var emergencyCTA: some View {
        Button {
            showEmergencyHelp = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "phone.arrow.up.right.fill")
                    .font(.system(size: 18, weight: .bold))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Get Emergency Help")
                        .font(.system(size: 16, weight: .bold))
                    Text("Tap for immediate guidance")
                        .font(.system(size: 12))
                        .opacity(0.8)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundStyle(.white)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.red)
            )
        }
        .padding(.horizontal)
    }

    private func actionCard(_ result: TriageResult) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(Color("baseColor"))
                    .font(.system(size: 16))
                Text("Recommended Action")
                    .font(.system(size: 16, weight: .bold))
            }

            Text(result.recommendedAction)
                .font(.system(size: 14))
                .foregroundStyle(Color("secondaryText"))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color("cardBackground"))
        )
        .padding(.horizontal)
    }

    private func possibleCausesSection(_ result: TriageResult) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Possible Causes")
                .font(.system(size: 18, weight: .bold))
                .padding(.horizontal)

            ForEach(result.matchedConditions) { match in
                conditionCard(match)
            }
        }
    }

    private func conditionCard(_ match: ConditionMatch) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header row
            HStack {
                Text(match.condition.name)
                    .font(.system(size: 16, weight: .bold))

                Spacer()

                SeverityBadgeView(severity: match.condition.severity)
            }

            // Match info
            HStack(spacing: 16) {
                Label(match.matchPercentageText, systemImage: "chart.bar.fill")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color("baseColor"))

                Label("\(match.matchedSymptomCount) symptom\(match.matchedSymptomCount == 1 ? "" : "s") matched",
                      systemImage: "checkmark.circle")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color("secondaryText"))
            }

            // Match progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color("secondaryCardBackground"))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(match.condition.severity.color)
                        .frame(width: geo.size.width * match.score, height: 6)
                }
            }
            .frame(height: 6)

            // Advice
            Text(match.condition.advice)
                .font(.system(size: 13))
                .foregroundStyle(Color("secondaryText"))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color("cardBackground"))
        )
        .padding(.horizontal)
    }

    private var disclaimerSection: some View {
        HStack(spacing: 8) {
            Image(systemName: "info.circle")
                .foregroundStyle(Color("secondaryText"))
                .font(.system(size: 14))

            Text("This is not a medical diagnosis. Always consult a veterinarian for proper evaluation and treatment.")
                .font(.system(size: 12))
                .foregroundStyle(Color("secondaryText"))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("secondaryCardBackground"))
        )
        .padding(.horizontal)
    }

    private var checkAgainButton: some View {
        Button {
            store.reset()
            dismiss()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 14, weight: .bold))
                Text("Check Again")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundStyle(Color("baseColor"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color("baseColor"), lineWidth: 1.5)
            )
        }
        .padding(.horizontal)
    }

    private var nearbyVetsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Nearby Veterinary Clinics")
                .font(.system(size: 18, weight: .bold))
                .padding(.horizontal)

            ForEach(vetManager.nearbyVets) { vet in
                NearbyVetCard(vet: vet)
            }
        }
        .padding(.top, 10)
    }
}

struct SymptomResultPreviewWrapper: View {
    @State private var store = SymptomStore()
    @State private var petStore = PetStore()

    var body: some View {
        NavigationStack {
            SymptomResultView()
                .environment(store)
                .environment(petStore)
        }
        .onAppear {
            store.toggleSymptom(Symptom(id: "vomiting", name: "Vomiting", category: .digestive, isEmergency: false))
            store.toggleSymptom(Symptom(id: "lethargy", name: "Lethargy", category: .general, isEmergency: false))
            store.toggleSymptom(Symptom(id: "diarrhea", name: "Diarrhea", category: .digestive, isEmergency: false))
            store.analyze()
        }
    }
}

#Preview {
    SymptomResultPreviewWrapper()
}
