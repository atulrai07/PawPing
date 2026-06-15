//
//  MedicationDetailView.swift
//  PawPing
//

import SwiftUI

struct MedicationDetailView: View {
    @Environment(MedicationStore.self) var store
    @Environment(\.dismiss) var dismiss
    @State private var showDeleteConfirmation = false
    @State private var showEditMedication = false
    
    let medication: Medication
    
    var liveMedication: Medication {
        store.medications.first(where: { $0.id == medication.id }) ?? medication
    }
    
    var body: some View {
        let med = liveMedication
        List {
            Section("Status") {
                HStack {
                    Text("Current Status")
                    Spacer()
                    Text(med.status.rawValue.capitalized)
                        .foregroundStyle(statusColor(for: med.status))
                        .fontWeight(.semibold)
                }
            }
            
            Section("Details") {
                detailRow(title: "Dosage", value: "\(med.dosage) \(med.unit.rawValue)")
                detailRow(title: "Frequency", value: med.frequency.rawValue)
                detailRow(title: "Start Date", value: med.startDate.formatted(date: .abbreviated, time: .omitted))
                
                if let endDate = med.endDate {
                    detailRow(title: "End Date", value: endDate.formatted(date: .abbreviated, time: .omitted))
                }
            }
            
            if !med.instructions.isEmpty || med.prescribingVet != nil {
                Section("Additional Info") {
                    if !med.instructions.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Instructions")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(med.instructions)
                        }
                    }
                    
                    if let vet = med.prescribingVet {
                        detailRow(title: "Prescribing Vet", value: vet)
                    }
                }
            }
            
            if !med.completedDoses.isEmpty {
                Section("Completion History") {
                    ForEach(med.completedDoses.sorted(by: >), id: \.self) { date in
                        Text(date.formatted(date: .abbreviated, time: .shortened))
                    }
                }
            }
            
            Section {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Text("Delete Medication")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .navigationTitle(med.name)
        .confirmationDialog("Delete \(med.name)?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                store.deleteMedication(id: med.id)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone and will remove all history for this medication.")
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    showEditMedication = true
                }
            }
        }
        .sheet(isPresented: $showEditMedication) {
            AddMedicationView(medicationToEdit: med)
        }
    }
    
    private func statusColor(for status: MedicationStatus) -> Color {
        switch status {
        case .active: return .green
        case .upcoming: return .blue
        case .completed: return .gray
        }
    }
    
    private func detailRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
        }
    }
}
