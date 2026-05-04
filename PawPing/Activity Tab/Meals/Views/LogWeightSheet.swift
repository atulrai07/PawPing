import SwiftUI

struct LogWeightSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(WeightStore.self) var weightStore
    @Environment(PetStore.self) var petStore
    
    let pet: Pet
    
    @State private var weightValue: String = ""
    @State private var unit: String = "kg"
    @State private var condition: BodyCondition = .ideal
    
    var helperText: String {
        switch condition {
        case .underweight:
            return "Ribs, lumbar vertebrae, and pelvic bones are easily visible. No palpable fat."
        case .ideal:
            return "Ribs are easily felt without excess fat. Waist is visible from above."
        case .overweight:
            return "Ribs are difficult to feel under a thick layer of fat. Waist is not visible."
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Weight") {
                    HStack {
                        TextField("0.0", text: $weightValue)
                            .keyboardType(.decimalPad)
                        
                        Picker("Unit", selection: $unit) {
                            Text("kg").tag("kg")
                            Text("lbs").tag("lbs")
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 100)
                    }
                }
                
                Section("Body Condition") {
                    Picker("Condition", selection: $condition) {
                        ForEach(BodyCondition.allCases, id: \.self) { type in
                            Text(type.label).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Text(helperText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                }
            }
            .navigationTitle("Log Weight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveRecord()
                    }
                    .disabled(Double(weightValue) == nil)
                }
            }
        }
    }
    
    private func saveRecord() {
        guard var weight = Double(weightValue) else { return }
        
        // Convert to kg if lbs selected
        if unit == "lbs" {
            weight = weight * 0.453592
        }
        
        weightStore.addRecord(petId: pet.id, weightKg: weight, condition: condition)
        
        // Update pet in Supabase
        var updatedPet = pet
        updatedPet.weightKg = weight
        Task {
            await petStore.updatePet(updatedPet)
        }
        
        dismiss()
    }
}
