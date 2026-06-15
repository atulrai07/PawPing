//
//  MedicationDetailView.swift
//  PawPing
//

import SwiftUI

struct MedicationDetailView: View {
    @Environment(MedicationStore.self) var store
    @Environment(\.dismiss) var dismiss
    @State private var showDeleteConfirmation = false
    
    let medication: Medication
    
    var body: some View {
        List {
            Section("Status") {
                HStack {
                    Text("Current Status")
                    Spacer()
                    Text(medication.status.rawValue.capitalized)
                        .foregroundStyle(statusColor)
                        .fontWeight(.semibold)
                }
            }
            
            Section("Details") {
                detailRow(title: "Dosage", value: "\(medication.dosage) \(medication.unit.rawValue)")
                detailRow(title: "Frequency", value: medication.frequency.rawValue)
                detailRow(title: "Start Date", value: medication.startDate.formatted(date: .abbreviated, time: .omitted))
                
                if let endDate = medication.endDate {
                    detailRow(title: "End Date", value: endDate.formatted(date: .abbreviated, time: .omitted))
                }
            }
            
            if !medication.instructions.isEmpty || medication.prescribingVet != nil {
                Section("Additional Info") {
                    if !medication.instructions.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Instructions")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(medication.instructions)
                        }
                    }
                    
                    if let vet = medication.prescribingVet {
                        detailRow(title: "Prescribing Vet", value: vet)
                    }
                }
            }
            
            if !medication.completedDoses.isEmpty {
                Section("Completion History") {
                    ForEach(medication.completedDoses.sorted(by: >), id: \.self) { date in
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
        .navigationTitle(medication.name)
        .confirmationDialog("Delete \(medication.name)?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                store.deleteMedication(id: medication.id)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone and will remove all history for this medication.")
        }
    }
    
    private var statusColor: Color {
        switch medication.status {
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
