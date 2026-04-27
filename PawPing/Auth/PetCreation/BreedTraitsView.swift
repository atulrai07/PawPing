//
//  BreedTraitsView.swift
//  PawPing
//

import SwiftUI

struct BreedTraitsView: View {
    @Environment(PetStore.self) var petStore
    @Environment(AppState.self) var appState
    
    let petName: String
    let breed: String
    let petData: (name: String, gender: PetGender, weight: Double, birthday: Date, isNeutered: Bool, image: String, imageData: Data?)
    let onComplete: () -> Void
    
    @State private var traits: BreedTrait? = nil
    @State private var isLoading = true
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorMessage = ""
    
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
                .padding(.bottom, 120)
            }
            
            // MARK: - Sticky Bottom Button
            VStack {
                Button {
                    saveAndContinue()
                } label: {
                    if isSaving {
                        ProgressView().tint(.white)
                            .frame(maxWidth: .infinity).frame(height: 56)
                            .background(Color("baseColor")).cornerRadius(16)
                    } else {
                        Text("Continue")
                            .font(.headline).foregroundStyle(.white)
                            .frame(maxWidth: .infinity).frame(height: 56)
                            .background(Color("baseColor")).cornerRadius(16)
                    }
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.bottom, 10)
            }
            .padding(.top, 12)
            .background(.ultraThinMaterial)
        }
        .navigationBarBackButtonHidden(isSaving)
        .onAppear { loadTraits() }
        .alert("Error Saving Pet", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func saveAndContinue() {
        isSaving = true
        
        Task {
            var finalImageName = petData.image
            
            // Upload image if selected
            if let data = petData.imageData {
                if let urlString = await petStore.uploadImage(data: data) {
                    finalImageName = urlString
                }
            }
            
            let newPet = Pet(
                id: UUID(),
                name: petData.name,
                breed: breed,
                gender: petData.gender,
                age: calculateAge(from: petData.birthday),
                weightKg: petData.weight,
                imageName: finalImageName,
                homeLatitude: 28.4210,
                homeLongitude: 77.5340,
                birthday: Pet.birthdayString(from: petData.birthday),
                isNeutered: petData.isNeutered
            )
            
            let success = await petStore.addPet(newPet)
            isSaving = false
            if success {
                onComplete()
            } else {
                errorMessage = petStore.lastError ?? "Unknown database error"
                showError = true
            }
        }
    }
    
    private func loadTraits() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.traits = BreedDataService.shared.traits(for: breed)
            self.isLoading = false
        }
    }
    
    private func calculateAge(from birthday: Date) -> String {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthday, to: Date())
        return "\(ageComponents.year ?? 0)"
    }
    
    @ViewBuilder
    private func traitRow(for trait: String, score: Int) -> some View {
        if let desc = BreedDataService.shared.description(for: trait) {
            TraitBarView(title: trait, lowLabel: desc.lowLabel, highLabel: desc.highLabel, score: score)
        } else {
            TraitBarView(title: trait, lowLabel: "Low", highLabel: "High", score: score)
        }
    }
}
