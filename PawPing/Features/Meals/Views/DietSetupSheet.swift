//
//  DietSetupSheet.swift
//  PawPing
//

import SwiftUI

struct DietSetupSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(PetStore.self) var petStore
    var store: MealStore

    @State private var weightInput: String = ""
    @State private var weightUnit: WeightUnit = .kg
    @State private var selectedGoal: DietGoal = .maintain

    private var weightKg: Double {
        let raw = Double(weightInput) ?? 0
        return weightUnit.toKg(raw)
    }

    private var previewRER: Double {
        guard weightKg > 0 else { return 0 }
        return 70.0 * pow(weightKg, 0.75)
    }

    private var previewTarget: Double { previewRER * selectedGoal.rerMultiplier }
    private var canStart: Bool { weightKg > 1 && weightKg < 150 }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    petInfoCard
                    weightSection
                    goalSection
                    if canStart { targetPreview.transition(.scale.combined(with: .opacity)) }
                    if canStart { startButton.transition(.opacity.combined(with: .move(edge: .bottom))) }
                }
                .padding(.horizontal).padding(.top, 8).padding(.bottom, 40)
            }
            .background(Color("baseBackground"))
            .navigationTitle("Diet Plan Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        ZStack {
                            Circle()
                                .fill(Color("cardBackground"))
                                .frame(width: 30, height: 30)
                                .shadow(color: .black.opacity(0.1), radius: 5)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Color("secondaryText"))
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .onAppear {
            if let currentKg = petStore.activePet?.weightKg, currentKg > 0 {
                weightInput = String(format: "%.1f", weightUnit.fromKg(currentKg))
            } else {
                weightInput = ""
            }
        }
    }

    private var petInfoCard: some View {
        HStack(spacing: 16) {
            Image(petStore.activePet?.imageName ?? Pet.defaultImageName).resizable().scaledToFill().frame(width: 50, height: 50).clipShape(Circle())
            VStack(alignment: .leading, spacing: 4) {
                Text(petStore.activePet?.name ?? "Pet").font(.system(size: 18, weight: .semibold))
                HStack(spacing: 12) {
                    Label(petStore.activePet?.breed ?? "—", systemImage: "pawprint.fill")
                    Label("\(petStore.activePet?.age ?? "?") yr", systemImage: "birthday.cake.fill")
                }.font(.system(size: 12)).foregroundStyle(Color("secondaryText"))
            }
            Spacer()
        }.padding(16).background(Color("cardBackground")).clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var weightSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Current Weight").font(.system(size: 14, weight: .semibold)).foregroundStyle(Color("secondaryText"))
            HStack(spacing: 12) {
                HStack {
                    TextField("e.g. 25", text: $weightInput).keyboardType(.decimalPad).font(.system(size: 20, weight: .semibold))
                    Text(weightUnit.rawValue).font(.system(size: 14)).foregroundStyle(Color("secondaryText"))
                }.padding(14).background(Color("cardBackground")).clipShape(RoundedRectangle(cornerRadius: 14))
                Picker("Unit", selection: $weightUnit) {
                    ForEach(WeightUnit.allCases) { Text($0.rawValue).tag($0) }
                }.pickerStyle(.segmented).frame(width: 100)
            }
        }
    }

    private var goalSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Goal").font(.system(size: 14, weight: .semibold)).foregroundStyle(Color("secondaryText"))
            HStack(spacing: 10) {
                ForEach(DietGoal.allCases) { goal in
                    Button { withAnimation { selectedGoal = goal } } label: {
                        VStack(spacing: 8) {
                            Image(systemName: goal.icon).font(.system(size: 22)).foregroundStyle(selectedGoal == goal ? .white : Color("baseColor"))
                            Text(goal.rawValue).font(.system(size: 11, weight: .medium)).foregroundStyle(selectedGoal == goal ? .white : .primary)
                        }.frame(maxWidth: .infinity).padding(.vertical, 14)
                        .background(RoundedRectangle(cornerRadius: 16).fill(selectedGoal == goal ? Color("baseColor") : Color("cardBackground")))
                    }.buttonStyle(.plain)
                }
            }
        }
    }

    private var targetPreview: some View {
        VStack(spacing: 12) {
            Text("Daily Calorie Target").font(.system(size: 13)).foregroundStyle(Color("secondaryText"))
            Text("\(Int(previewTarget)) kcal/day").font(.system(size: 32, weight: .bold)).foregroundStyle(Color("baseColor"))
            HStack(spacing: 16) {
                previewStat(label: "RER", value: "\(Int(previewRER))")
                Rectangle().fill(Color("secondaryCardBackground")).frame(width: 1, height: 24)
                previewStat(label: "Multiplier", value: "×\(String(format: "%.1f", selectedGoal.rerMultiplier))")
                Rectangle().fill(Color("secondaryCardBackground")).frame(width: 1, height: 24)
                previewStat(label: "Weight", value: "\(String(format: "%.1f", weightKg)) kg")
            }
        }.padding(20).frame(maxWidth: .infinity).background(RoundedRectangle(cornerRadius: 20).fill(Color("baseColor").opacity(0.06)))
    }
    
    private func previewStat(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(label).font(.system(size: 11)).foregroundStyle(Color("secondaryText"))
            Text(value).font(.system(size: 14, weight: .semibold))
        }
    }

    private var startButton: some View {
        Button {
            store.startDiet(goal: selectedGoal, weightKg: weightKg)
            if var pet = petStore.activePet {
                pet.weightKg = weightKg
                Task { await petStore.updatePet(pet) }
            }
            dismiss()
        } label: {
            HStack(spacing: 8) { Image(systemName: "play.circle.fill"); Text("Start Diet Plan") }
                .font(.system(size: 17, weight: .semibold)).foregroundStyle(.white).frame(maxWidth: .infinity).padding(.vertical, 16)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color("baseColor")))
        }
    }
}
