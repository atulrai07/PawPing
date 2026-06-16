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
            
            if rec.isCompleted || rec.vetName != nil || rec.vetAddress != nil || rec.vetPhone != nil {
                Section("Vet Clinic") {
                    HStack {
                        Text("Clinic Name")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(rec.vetName ?? "Not Specified")
                            .foregroundStyle(rec.vetName == nil ? .secondary : .primary)
                    }
                    
                    if let address = rec.vetAddress, !address.isEmpty {
                        detailRow(title: "Address", value: address)
                    }
                    
                    HStack {
                        Text("Phone")
                            .foregroundStyle(.secondary)
                        Spacer()
                        if let phone = rec.vetPhone, !phone.isEmpty {
                            let cleanedPhone = phone.filter { "+0123456789".contains($0) }
                            if !cleanedPhone.isEmpty {
                                Button {
                                    if let url = URL(string: "tel://\(cleanedPhone)") {
                                        UIApplication.shared.open(url)
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "phone.fill")
                                            .font(.system(size: 12))
                                        Text(phone)
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundStyle(Color("baseColor"))
                                }
                                .buttonStyle(.plain)
                            } else {
                                Text(phone)
                            }
                        } else {
                            Text("Not Specified")
                                .foregroundStyle(.secondary)
                        }
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
                    Text("Delete \(rec.recordType.displayName)")
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
