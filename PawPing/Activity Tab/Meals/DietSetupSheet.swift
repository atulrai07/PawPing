//
//  DietSetupSheet.swift
//  PawPing
//
//  Created by Atul on 25/04/26.
//
//

import SwiftUI

struct DietSetupSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(PetStore.self) var petStore

    var store: ActivityStore

    // MARK: - Local State

    @State private var weightInput: String = ""
    @State private var weightUnit: WeightUnit = .kg
    @State private var selectedGoal: DietGoal = .maintain

    // Derived weight in kg for calculation
    private var weightKg: Double {
        let raw = Double(weightInput) ?? 0
        return weightUnit.toKg(raw)
    }

    // Live RER calculation
    private var previewRER: Double {
        guard weightKg > 0 else { return 0 }
        return 70.0 * pow(weightKg, 0.75)
    }

    private var previewTarget: Double {
        previewRER * selectedGoal.rerMultiplier
    }

    private var canStart: Bool {
        weightKg > 1 && weightKg < 150 // reasonable range for dogs
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    // Pet Info (read-only)
                    petInfoCard

                    // Weight Input
                    weightSection

                    // Goal Picker
                    goalSection

                    // Live Target Preview
                    if canStart {
                        targetPreview
                            .transition(.scale.combined(with: .opacity))
                    }

                    // Start Button
                    if canStart {
                        startButton
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 40)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: canStart)
                .animation(.easeInOut(duration: 0.3), value: previewTarget)
            }
            .background(Color("baseBackground"))
            .navigationTitle("Diet Plan Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
        .onAppear {
            // Pre-fill with existing weight
            let currentKg = petStore.activePet?.weightKg ?? 10.0
            weightInput = String(format: "%.1f", weightUnit.fromKg(currentKg))
        }
    }

    // MARK: - Pet Info Card (read-only)

    private var petInfoCard: some View {
        HStack(spacing: 16) {
            if let urlString = petStore.activePet?.profileImageUrl, let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            } else {
                Image(petStore.activePet?.imageName ?? Pet.defaultImageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(petStore.activePet?.name ?? "Pet")
                    .font(.system(size: 18, weight: .semibold))

                HStack(spacing: 12) {
                    Label(petStore.activePet?.breed ?? "—", systemImage: "pawprint.fill")
                    Label("\(petStore.activePet?.age ?? "?") yr", systemImage: "birthday.cake.fill")
                }
                .font(.system(size: 12))
                .foregroundStyle(Color("secondaryText"))
            }

            Spacer()
        }
        .padding(16)
        .background(Color("cardBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Weight Section

    private var weightSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Current Weight")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color("secondaryText"))

            HStack(spacing: 12) {
                HStack {
                    TextField("e.g. 25", text: $weightInput)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 20, weight: .semibold))

                    Text(weightUnit.rawValue)
                        .font(.system(size: 14))
                        .foregroundStyle(Color("secondaryText"))
                }
                .padding(14)
                .background(Color("cardBackground"))
                .clipShape(RoundedRectangle(cornerRadius: 14))

                // Unit toggle
                Picker("Unit", selection: $weightUnit) {
                    ForEach(WeightUnit.allCases) { unit in
                        Text(unit.rawValue).tag(unit)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 100)
                .onChange(of: weightUnit) { oldUnit, newUnit in
                    // Convert the displayed value when switching units
                    if let raw = Double(weightInput) {
                        let kg = oldUnit.toKg(raw)
                        weightInput = String(format: "%.1f", newUnit.fromKg(kg))
                    }
                }
            }
        }
    }

    // MARK: - Goal Section

    private var goalSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Goal")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color("secondaryText"))

            HStack(spacing: 10) {
                ForEach(DietGoal.allCases) { goal in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedGoal = goal
                        }
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: goal.icon)
                                .font(.system(size: 22))
                                .foregroundStyle(selectedGoal == goal ? .white : Color("baseColor"))

                            Text(goal.rawValue)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(selectedGoal == goal ? .white : .primary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(selectedGoal == goal ? Color("baseColor") : Color("cardBackground"))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(selectedGoal == goal ? Color.clear : Color("secondaryCardBackground"), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Target Preview

    private var targetPreview: some View {
        VStack(spacing: 12) {
            Text("Daily Calorie Target")
                .font(.system(size: 13))
                .foregroundStyle(Color("secondaryText"))

            Text("\(Int(previewTarget)) kcal/day")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(Color("baseColor"))
                .contentTransition(.numericText())

            HStack(spacing: 16) {
                VStack(spacing: 2) {
                    Text("RER")
                        .font(.system(size: 11))
                        .foregroundStyle(Color("secondaryText"))
                    Text("\(Int(previewRER))")
                        .font(.system(size: 14, weight: .semibold))
                }
                
                Rectangle()
                    .fill(Color("secondaryCardBackground"))
                    .frame(width: 1, height: 24)

                VStack(spacing: 2) {
                    Text("Multiplier")
                        .font(.system(size: 11))
                        .foregroundStyle(Color("secondaryText"))
                    Text("×\(String(format: "%.1f", selectedGoal.rerMultiplier))")
                        .font(.system(size: 14, weight: .semibold))
                }

                Rectangle()
                    .fill(Color("secondaryCardBackground"))
                    .frame(width: 1, height: 24)

                VStack(spacing: 2) {
                    Text("Weight")
                        .font(.system(size: 11))
                        .foregroundStyle(Color("secondaryText"))
                    Text("\(String(format: "%.1f", weightKg)) kg")
                        .font(.system(size: 14, weight: .semibold))
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color("baseColor").opacity(0.06))
        )
    }

    // MARK: - Start Button

    private var startButton: some View {
        Button {
            store.mealDietStore.startDiet(goal: selectedGoal, weightKg: weightKg)
            if var pet = petStore.activePet {
                pet.weightKg = weightKg
                Task {
                    await petStore.updatePet(pet)
                }
            }
            dismiss()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "play.circle.fill")
                Text("Start Diet Plan")
            }
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("baseColor"))
            )
        }
    }
}

#Preview {
    DietSetupSheet(store: ActivityStore())
}
