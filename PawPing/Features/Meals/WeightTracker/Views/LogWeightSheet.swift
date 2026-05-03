//
//  LogWeightSheet.swift
//  PawPing
//

import SwiftUI

struct LogWeightSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(WeightStore.self) var weightStore
    @Environment(PetStore.self) var petStore

    @State private var weightInput: String = ""
    @State private var weightUnit: WeightUnit = .kg
    @State private var selectedCondition: BodyCondition = .ideal
    @State private var isSaving: Bool = false

    private var weightKg: Double {
        let raw = Double(weightInput) ?? 0
        return weightUnit.toKg(raw)
    }

    private var canSave: Bool {
        weightKg > 1 && weightKg < 150 && !isSaving
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    weightSection
                    conditionSection
                    saveButton
                }
                .padding()
            }
            .background(Color("baseBackground"))
            .navigationTitle("Log Check-in")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Color("baseColor"))
                }
            }
            .onAppear {
                if let currentKg = petStore.activePet?.weightKg, currentKg > 0 {
                    weightInput = String(format: "%.1f", weightUnit.fromKg(currentKg))
                }
                if let latest = weightStore.latest {
                    selectedCondition = latest.bodyCondition
                }
            }
        }
    }

    private var weightSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Weight")
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
                
                Picker("Unit", selection: $weightUnit) {
                    ForEach(WeightUnit.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                .frame(width: 100)
            }
        }
    }

    private var conditionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Body Condition")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color("secondaryText"))

            Picker("Body Condition", selection: $selectedCondition) {
                ForEach(BodyCondition.allCases, id: \.self) { condition in
                    Text(condition.label).tag(condition)
                }
            }
            .pickerStyle(.segmented)
            
            Text(conditionHelperText)
                .font(.system(size: 13))
                .foregroundStyle(Color("secondaryText"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)
        }
    }

    private var conditionHelperText: String {
        switch selectedCondition {
        case .underweight:
            return "Ribs and spine easily visible, little muscle mass"
        case .ideal:
            return "Ribs felt easily, waist visible, good muscle tone"
        case .overweight:
            return "Ribs hard to feel, no visible waist, rounded belly"
        }
    }

    private var saveButton: some View {
        Button {
            saveRecord()
        } label: {
            HStack(spacing: 8) {
                if isSaving {
                    ProgressView().tint(.white)
                } else {
                    Text("Save Log")
                }
            }
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color("baseColor").opacity(canSave ? 1.0 : 0.5)))
        }
        .disabled(!canSave)
    }

    private func saveRecord() {
        guard let petId = petStore.activePetId, canSave else { return }
        isSaving = true
        
        // 1. Add to local weight store
        weightStore.addRecord(petId: petId, weightKg: weightKg, condition: selectedCondition)
        
        // 2. Update pet profile
        if var pet = petStore.activePet {
            pet.weightKg = weightKg
            Task {
                try? await petStore.updatePet(pet)
                await MainActor.run {
                    isSaving = false
                    dismiss()
                }
            }
        } else {
            isSaving = false
            dismiss()
        }
    }
}
