//
//  HealthRecordDetailView.swift
//  PawPing
//

import SwiftUI

struct HealthRecordDetailView: View {
    @Environment(HealthStore.self) var store
    @Environment(\.dismiss) var dismiss
    @State private var showDeleteConfirmation = false
    @State private var showEditRecord = false
    
    let record: HealthRecord
    
    var liveRecord: HealthRecord {
        store.healthRecords.first(where: { $0.id == record.id }) ?? record
    }
    
    var body: some View {
        let rec = liveRecord
        List {
            Section("Status") {
                HStack {
                    Text("Current Status")
                    Spacer()
                    Text(rec.status.rawValue.capitalized)
                        .foregroundStyle(statusColor(for: rec.status))
                        .fontWeight(.semibold)
                }
            }
            
            Section("Details") {
                detailRow(title: "Vaccinated Date", value: rec.dateGiven.formatted(date: .abbreviated, time: .omitted))
                
                if let nextDose = rec.nextDoseDate {
                    detailRow(title: "Next Dose", value: nextDose.formatted(date: .abbreviated, time: .omitted))
                }
            }
            
            if rec.vetName != nil || rec.vetAddress != nil || rec.vetPhone != nil {
                Section("Vet Clinic") {
                    if let name = rec.vetName {
                        detailRow(title: "Clinic Name", value: name)
                    }
                    if let address = rec.vetAddress {
                        detailRow(title: "Address", value: address)
                    }
                    if let phone = rec.vetPhone {
                        detailRow(title: "Phone", value: phone)
                    }
                }
            }
            
            if !rec.notes.isEmpty {
                Section("Notes") {
                    Text(rec.notes)
                }
            }
            
            Section {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Text("Delete Vaccination")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .navigationTitle(rec.name)
        .confirmationDialog("Delete \(rec.name)?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                Task {
                    await store.deleteHealthRecord(id: rec.id, petId: rec.petId)
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone and will remove all history for this record.")
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    showEditRecord = true
                }
            }
        }
        .sheet(isPresented: $showEditRecord) {
            AddHealthRecordView(petId: rec.petId, recordToEdit: rec)
        }
    }
    
    private func statusColor(for status: HealthStatus) -> Color {
        switch status {
        case .done: return .green
        case .upcoming: return .blue
        case .overdue: return .red
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
