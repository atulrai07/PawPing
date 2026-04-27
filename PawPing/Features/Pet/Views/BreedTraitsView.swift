//
//  BreedTraitsView.swift
//  PawPing
//

import SwiftUI

struct BreedTraitsView: View {
    let petName: String
    let breed: String
    let onContinue: () -> Void
    
    @State private var traits: BreedTrait? = nil
    @State private var isLoading = true
    
    private let horizontalPadding: CGFloat = 16
    private let cardCornerRadius: CGFloat = 20
    private let rowGap: CGFloat = 12
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // MARK: - Header Block
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What makes \(petName) special?")
                            .font(.title2)
                            .bold()
                        
                        Text("These are common breed traits - \(petName) may be different, and that's totally okay!")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.top, 20)
                    
                    if isLoading {
                        VStack(spacing: 12) {
                            ProgressView()
                            Text("Loading breed info...")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 100)
                    } else if let traits = traits {
                        // MARK: - Traits Card
                        VStack(spacing: rowGap) {
                            traitRow(for: "Affectionate with Family", score: traits.affectionateWithFamily)
                            Divider()
                            traitRow(for: "Good with Other Dogs", score: traits.goodWithOtherDogs)
                            Divider()
                            traitRow(for: "Energy Level", score: traits.energyLevel)
                            Divider()
                            traitRow(for: "Mental Stimulation Needs", score: traits.mentalStimulationNeeds)
                            Divider()
                            traitRow(for: "Trainability Level", score: traits.trainabilityLevel)
                            Divider()
                            traitRow(for: "Watchdog Nature", score: traits.watchdogNature)
                        }
                        .padding(horizontalPadding)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius))
                        .padding(.horizontal, horizontalPadding)
                    } else {
                        // Fallback if breed not found
                        VStack(spacing: 16) {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(.secondary)
                            Text("We couldn't find specific traits for this breed, but you can still continue!")
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 40)
                        }
                        .padding(.top, 100)
                    }
                }
                .padding(.bottom, 120) // Space for bottom button
            }
            
            // MARK: - Sticky Bottom Button
            VStack {
                Button {
                    onContinue()
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color("baseColor"))
                        .cornerRadius(16)
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.bottom, 10)
            }
            .padding(.top, 12)
            .background(.ultraThinMaterial)
        }
        .navigationBarBackButtonHidden(false)
        .onAppear {
            loadTraits()
        }
    }
    
    private func loadTraits() {
        // Design: Small delay to show a loading state for better "discovery" feel
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.traits = BreedDataService.shared.traits(for: breed)
            self.isLoading = false
        }
    }
    
    @ViewBuilder
    private func traitRow(for trait: String, score: Int) -> some View {
        if let desc = BreedDataService.shared.description(for: trait) {
            TraitBarView(
                title: trait,
                lowLabel: desc.lowLabel,
                highLabel: desc.highLabel,
                score: score
            )
        } else {
            // Fallback labels if description not found
            TraitBarView(
                title: trait,
                lowLabel: "Low",
                highLabel: "High",
                score: score
            )
        }
    }
}

#Preview {
    NavigationStack {
        BreedTraitsView(petName: "Buddy", breed: "Labrador") {
            print("Continue tapped")
        }
    }
}
