//
//  AddHealthRecordView.swift
//  PawPing
//
//  Created by SidMoon on 28/03/26.
//  Refactored for Health system on 27/04/26.
//

import SwiftUI
import MapKit

enum DoseFrequency: String, CaseIterable {
    case monthly = "Every 1 Month"
    case quarterly = "Every 3 Months"
    case semiAnnually = "Every 6 Months"
    case annually = "Every 1 Year"
    case threeYears = "Every 3 Years"
    case custom = "Custom"
    
    var calendarValue: (component: Calendar.Component, value: Int)? {
        switch self {
        case .monthly: return (.month, 1)
        case .quarterly: return (.month, 3)
        case .semiAnnually: return (.month, 6)
        case .annually: return (.year, 1)
        case .threeYears: return (.year, 3)
        case .custom: return nil
        }
    }
}

struct AddHealthRecordView: View {

    @Environment(HealthStore.self) var healthStore
    @Environment(PetStore.self) var petStore
    @Environment(\.dismiss) private var dismiss
    
    let petId: UUID
    let recordToEdit: HealthRecord?

    // MARK: - State
    
    @State private var recordType: HealthRecordType
    @State private var name: String
    @State private var dateGiven: Date
    @State private var nextDoseDate: Date?
    @State private var hasNextDose: Bool
    @State private var frequency: DoseFrequency
    @State private var notes: String
    
    // Vet Clinic State
    @State private var vetName: String
    @State private var vetAddress: String
    @State private var vetPhone: String
    @State private var vetLatitude: Double?
    @State private var vetLongitude: Double?
    
    @State private var showingVetSearch = false
    @State private var errorMessage: String? = nil
    @State private var showError = false
    @State private var isSaving = false
    
    init(petId: UUID, recordToEdit: HealthRecord? = nil) {
        self.petId = petId
        self.recordToEdit = recordToEdit
        
        if let rec = recordToEdit {
            _recordType = State(initialValue: rec.recordType)
            _name = State(initialValue: rec.name)
            _dateGiven = State(initialValue: rec.dateGiven)
            _nextDoseDate = State(initialValue: rec.nextDoseDate)
            _hasNextDose = State(initialValue: rec.nextDoseDate != nil)
            _frequency = State(initialValue: .custom)
            _notes = State(initialValue: rec.notes)
            _vetName = State(initialValue: rec.vetName ?? "")
            _vetAddress = State(initialValue: rec.vetAddress ?? "")
            _vetPhone = State(initialValue: rec.vetPhone ?? "")
            _vetLatitude = State(initialValue: rec.vetLatitude)
            _vetLongitude = State(initialValue: rec.vetLongitude)
        } else {
            _recordType = State(initialValue: .vaccine)
            _name = State(initialValue: "")
            _dateGiven = State(initialValue: Date())
            _nextDoseDate = State(initialValue: nil)
            _hasNextDose = State(initialValue: false)
            _frequency = State(initialValue: .annually)
            _notes = State(initialValue: "")
            _vetName = State(initialValue: "")
            _vetAddress = State(initialValue: "")
            _vetPhone = State(initialValue: "")
            _vetLatitude = State(initialValue: nil)
            _vetLongitude = State(initialValue: nil)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Record Type") {
                    Picker("Type", selection: $recordType) {
                        ForEach(HealthRecordType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: recordType) { _, _ in
                        if recordType == .deworming {
                            hasNextDose = true
                            frequency = .quarterly
                        } else if recordType == .fleaTick {
                            hasNextDose = true
                            frequency = .monthly
                        } else {
                            hasNextDose = false
                        }
                        updateNextDoseDate()
                    }
                }
                
                Section("Details") {
                    HStack {
                        Text("Name")
                        Spacer()
                        Menu {
                            if recordType == .vaccine {
                                ForEach(CommonHealthRecords.vaccines, id: \.self) { vName in
                                    Button(vName) { name = vName }
                                }
                            } else if recordType == .deworming {
                                ForEach(CommonHealthRecords.deworming, id: \.self) { dName in
                                    Button(dName) { name = dName }
                                }
                            } else if recordType == .fleaTick {
                                ForEach(CommonHealthRecords.fleaTick, id: \.self) { fName in
                                    Button(fName) { name = fName }
                                }
                            }
                        } label: {
                            Text(name.isEmpty ? "Select or Type" : name)
                                .foregroundStyle(name.isEmpty ? .secondary : .primary)
                        }
                    }
                    
                    TextField("Custom Name", text: $name)
                    
                    DatePicker("Date Given", selection: $dateGiven, in: ...Date(), displayedComponents: .date)
                        .onChange(of: dateGiven) { _, _ in updateNextDoseDate() }
                    
                    Toggle("Set Reminder for Next Dose", isOn: $hasNextDose)
                        .onChange(of: hasNextDose) { _, _ in if hasNextDose { updateNextDoseDate() } }
                    
                    if hasNextDose {
                        Picker("Frequency", selection: $frequency) {
                            ForEach(DoseFrequency.allCases, id: \.self) { freq in
                                Text(freq.rawValue).tag(freq)
                            }
                        }
                        .onChange(of: frequency) { _, _ in updateNextDoseDate() }
                        
                        DatePicker("Next Dose", selection: Binding(
                            get: { nextDoseDate ?? Calendar.current.date(byAdding: .year, value: 1, to: dateGiven)! },
                            set: { 
                                nextDoseDate = $0
                                frequency = .custom
                            }
                        ), in: dateGiven..., displayedComponents: .date)
                    }
                }
                
                Section("Vet Clinic") {
                    Button {
                        showingVetSearch = true
                    } label: {
                        Label("Select from Map", systemImage: "map.fill")
                            .foregroundStyle(.pawPrimary)
                    }
                    
                    if !vetName.isEmpty || !vetAddress.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Clinic/Vet Name", text: $vetName)
                                .font(.headline)
                            
                            TextField("Address", text: $vetAddress)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            TextField("Phone", text: $vetPhone)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .keyboardType(.phonePad)
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                Section("Notes") {
                    TextField("Add any additional notes here...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(recordToEdit == nil ? "Add Health Record" : "Edit Health Record")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveRecord()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSaving)
                    .fontWeight(.bold)
                }
            }
            .sheet(isPresented: $showingVetSearch) {
                VetSearchView { mapItem in
                    handleVetSelection(mapItem)
                }
            }
            .alert("Error", isPresented: $showError, actions: {
                Button("OK") { }
            }, message: {
                Text(errorMessage ?? "Unknown error occurred")
            })
            .overlay {
                if isSaving {
                    ProgressView("Saving...")
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func handleVetSelection(_ item: MKMapItem) {
        vetName = item.name ?? ""
        vetAddress = item.address?.fullAddress ?? ""
        vetPhone = item.phoneNumber ?? ""
        vetLatitude = item.location.coordinate.latitude
        vetLongitude = item.location.coordinate.longitude
    }
    
    private func updateNextDoseDate() {
        if let config = frequency.calendarValue {
            nextDoseDate = Calendar.current.date(byAdding: config.component, value: config.value, to: dateGiven)
        } else if nextDoseDate == nil {
            // Default to 1 year if custom is selected but no date set yet
            nextDoseDate = Calendar.current.date(byAdding: .year, value: 1, to: dateGiven)
        }
    }
    
    private func saveRecord() {
        guard !name.isEmpty else { return }
        
        isSaving = true
        
        let record = HealthRecord(
            id: recordToEdit?.id ?? UUID(),
            petId: petId,
            type: recordType.rawValue,
            name: name,
            dateGiven: dateGiven,
            nextDoseDate: hasNextDose ? (nextDoseDate ?? Calendar.current.date(byAdding: .year, value: 1, to: dateGiven)) : nil,
            notes: notes,
            isCompleted: recordToEdit?.isCompleted ?? false,
            vetName: vetName.isEmpty ? nil : vetName,
            vetAddress: vetAddress.isEmpty ? nil : vetAddress,
            vetPhone: vetPhone.isEmpty ? nil : vetPhone,
            vetLatitude: vetLatitude,
            vetLongitude: vetLongitude
        )
        
        Task {
            if recordToEdit != nil {
                print("📝 Attempting to update health record: \(record.name)")
                await healthStore.updateHealthRecord(record)
            } else {
                print("📝 Attempting to save health record: \(record.name)")
                await healthStore.addHealthRecord(record)
            }
            // Ensure UI is fully refreshed
            await healthStore.fetchVaccines(for: petId)
            isSaving = false
            dismiss()
        }
    }
}

#Preview {
    AddHealthRecordView(petId: UUID())
        .environment(HealthStore())
        .environment(PetStore())
}
