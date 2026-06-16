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
    @State private var showLogDoseSheet = false
    @State private var selectedSlot: Medication.DoseSlot? = nil
    @State private var timeGiven = Date()
    
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
            
            if med.isActive(on: Date()) {
                Section("Today's Schedule") {
                    let slots = med.doseSlots(for: Date())
                    ForEach(slots) { slot in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(slot.time)
                                    .font(.headline)
                                
                                if let date = slot.completedDate {
                                    Text("Taken at \(date.formatted(date: .omitted, time: .shortened))")
                                        .font(.subheadline)
                                        .foregroundStyle(.green)
                                } else {
                                    Text("Pending")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            if let _ = slot.completedDate {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                                    .font(.title2)
                            } else {
                                Button {
                                    selectedSlot = slot
                                    timeGiven = Date()
                                    showLogDoseSheet = true
                                } label: {
                                    if slot.time == "As Needed" {
                                        Label("Log Dose", systemImage: "plus.circle.fill")
                                            .foregroundStyle(Color("baseColor"))
                                            .fontWeight(.semibold)
                                    } else {
                                        Image(systemName: "circle")
                                            .foregroundStyle(.secondary)
                                            .font(.title2)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 4)
                    }
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
        .sheet(isPresented: $showLogDoseSheet) {
            if let slot = selectedSlot {
                NavigationStack {
                    VStack(spacing: 24) {
                        VStack(spacing: 8) {
                            Image(systemName: "pills.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(Color("baseColor"))
                                .padding()
                                .background(Color("baseColor").opacity(0.1))
                                .clipShape(Circle())
                            
                            Text("Log Dose")
                                .font(.title2)
                                .bold()
                            
                            Text("Log dose for \(med.name) (\(med.dosage) \(med.unit.rawValue)) scheduled for \(slot.time).")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.top, 24)
                        
                        DatePicker("Time Given", selection: $timeGiven, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                        
                        Spacer()
                        
                        Button {
                            store.logDose(for: med.id, date: timeGiven)
                            showLogDoseSheet = false
                        } label: {
                            Text("Confirm Done")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color("baseColor"))
                                .cornerRadius(16)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                    }
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                showLogDoseSheet = false
                            }
                        }
                    }
                }
                .presentationDetents([.medium])
            }
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
