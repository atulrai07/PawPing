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

    // MARK: - State
    
    @State private var recordType: HealthRecordType = .vaccine
    @State private var name: String = ""
    @State private var dateGiven: Date = Date()
    @State private var nextDoseDate: Date? = nil
    @State private var hasNextDose: Bool = false
    @State private var frequency: DoseFrequency = .annually
    @State private var notes: String = ""
    
    // Vet Clinic State
    @State private var vetName: String = ""
    @State private var vetAddress: String = ""
    @State private var vetPhone: String = ""
    @State private var vetLatitude: Double? = nil
    @State private var vetLongitude: Double? = nil
    
    @State private var showingVetSearch = false
    @State private var errorMessage: String? = nil
    @State private var showError = false
    @State private var isSaving = false
    
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
                }
                
                Section("Details") {
                    HStack {
                        Text("Name")
                        Spacer()
                        if recordType == .vaccine {
                            Menu {
                                ForEach(CommonHealthRecords.vaccines, id: \.self) { vName in
                                    Button(vName) { name = vName }
                                }
                            } label: {
                                Text(name.isEmpty ? "Select or Type" : name)
                                    .foregroundStyle(name.isEmpty ? .secondary : .primary)
                            }
                        } else {
                            Menu {
                                ForEach(CommonHealthRecords.deworming, id: \.self) { dName in
                                    Button(dName) { name = dName }
                                }
                            } label: {
                                Text(name.isEmpty ? "Select or Type" : name)
                                    .foregroundStyle(name.isEmpty ? .secondary : .primary)
                            }
                        }
                    }
                    
                    TextField("Custom Name", text: $name)
                    
                    DatePicker("Date Given", selection: $dateGiven, in: ...Date(), displayedComponents: .date)
                        .onChange(of: dateGiven) { updateNextDoseDate() }
                    
                    Toggle("Set Reminder for Next Dose", isOn: $hasNextDose)
                        .onChange(of: hasNextDose) { if hasNextDose { updateNextDoseDate() } }
                    
                    if hasNextDose {
                        Picker("Frequency", selection: $frequency) {
                            ForEach(DoseFrequency.allCases, id: \.self) { freq in
                                Text(freq.rawValue).tag(freq)
                            }
                        }
                        .onChange(of: frequency) { updateNextDoseDate() }
                        
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
            .navigationTitle("Add Health Record")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveRecord()
                    }
                    .disabled(name.isEmpty)
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
        vetAddress = item.placemark.title ?? ""
        vetPhone = item.phoneNumber ?? ""
        vetLatitude = item.placemark.coordinate.latitude
        vetLongitude = item.placemark.coordinate.longitude
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
            id: UUID(),
            petId: petId,
            type: recordType.rawValue,
            name: name,
            dateGiven: dateGiven,
            nextDoseDate: hasNextDose ? (nextDoseDate ?? Calendar.current.date(byAdding: .year, value: 1, to: dateGiven)) : nil,
            notes: notes,
            vetName: vetName.isEmpty ? nil : vetName,
            vetAddress: vetAddress.isEmpty ? nil : vetAddress,
            vetPhone: vetPhone.isEmpty ? nil : vetPhone,
            vetLatitude: vetLatitude,
            vetLongitude: vetLongitude
        )
        
        Task {
            do {
                await healthStore.addHealthRecord(record)
                isSaving = false
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
                isSaving = false
            }
        }
    }
}

#Preview {
    AddHealthRecordView(petId: UUID())
        .environment(HealthStore())
        .environment(PetStore())
}
