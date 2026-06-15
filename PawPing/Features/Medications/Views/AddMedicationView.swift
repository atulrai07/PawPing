//
//  AddMedicationView.swift
//  PawPing
//

import SwiftUI
import MapKit

struct AddMedicationView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(MedicationStore.self) var store
    @Environment(PetStore.self) var petStore
    
    let medicationToEdit: Medication?
    
    @State private var name: String
    @State private var dosage: String
    @State private var unit: MedicationUnit
    @State private var frequency: MedicationFrequency
    @State private var startDate: Date
    @State private var hasEndDate: Bool
    @State private var endDate: Date
    @State private var instructions: String
    
    // Vet Clinic State
    @State private var vetName: String
    @State private var vetAddress: String
    @State private var vetPhone: String
    @State private var vetLatitude: Double?
    @State private var vetLongitude: Double?
    @State private var showingVetSearch = false
    
    init(medicationToEdit: Medication? = nil) {
        self.medicationToEdit = medicationToEdit
        
        if let med = medicationToEdit {
            _name = State(initialValue: med.name)
            _dosage = State(initialValue: med.dosage)
            _unit = State(initialValue: med.unit)
            _frequency = State(initialValue: med.frequency)
            _startDate = State(initialValue: med.startDate)
            if let endDate = med.endDate {
                _hasEndDate = State(initialValue: true)
                _endDate = State(initialValue: endDate)
            } else {
                _hasEndDate = State(initialValue: false)
                _endDate = State(initialValue: Date().addingTimeInterval(86400 * 7))
            }
            _instructions = State(initialValue: med.instructions)
            _vetName = State(initialValue: med.prescribingVet ?? "")
            _vetAddress = State(initialValue: med.vetAddress ?? "")
            _vetPhone = State(initialValue: med.vetPhone ?? "")
            _vetLatitude = State(initialValue: med.vetLatitude)
            _vetLongitude = State(initialValue: med.vetLongitude)
        } else {
            _name = State(initialValue: "")
            _dosage = State(initialValue: "")
            _unit = State(initialValue: .tablet)
            _frequency = State(initialValue: .onceDaily)
            _startDate = State(initialValue: Date())
            _hasEndDate = State(initialValue: false)
            _endDate = State(initialValue: Date().addingTimeInterval(86400 * 7))
            _instructions = State(initialValue: "")
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
                Section("Medication Details") {
                    TextField("Medication Name", text: $name)
                    
                    HStack {
                        TextField("Dosage (e.g. 1, 5)", text: $dosage)
                            .keyboardType(.decimalPad)
                        Picker("Unit", selection: $unit) {
                            ForEach(MedicationUnit.allCases, id: \.self) { u in
                                Text(u.rawValue).tag(u)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    
                    Picker("Frequency", selection: $frequency) {
                        ForEach(MedicationFrequency.allCases, id: \.self) { f in
                            Text(f.rawValue).tag(f)
                        }
                    }
                }
                
                Section("Schedule") {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    
                    Toggle("Has End Date?", isOn: $hasEndDate)
                    
                    if hasEndDate {
                        DatePicker("End Date", selection: $endDate, in: startDate..., displayedComponents: .date)
                    }
                }
                
                Section("Additional Info") {
                    TextField("Special Instructions", text: $instructions)
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
            }
            .navigationTitle(medicationToEdit == nil ? "Add Medication" : "Edit Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(name.isEmpty || dosage.isEmpty)
                }
            }
            .sheet(isPresented: $showingVetSearch) {
                VetSearchView { mapItem in
                    handleVetSelection(mapItem)
                }
            }
        }
    }
    
    private func handleVetSelection(_ item: MKMapItem) {
        vetName = item.name ?? ""
        vetAddress = item.address?.fullAddress ?? ""
        vetPhone = item.phoneNumber ?? ""
        vetLatitude = item.location.coordinate.latitude
        vetLongitude = item.location.coordinate.longitude
    }
    
    private func save() {
        guard let petId = petStore.activePetId else { return }
        let med = Medication(
            id: medicationToEdit?.id ?? UUID(),
            petId: petId,
            name: name,
            dosage: dosage,
            unit: unit,
            frequency: frequency,
            startDate: startDate,
            endDate: hasEndDate ? endDate : nil,
            instructions: instructions,
            prescribingVet: vetName.isEmpty ? nil : vetName,
            vetAddress: vetAddress.isEmpty ? nil : vetAddress,
            vetPhone: vetPhone.isEmpty ? nil : vetPhone,
            vetLatitude: vetLatitude,
            vetLongitude: vetLongitude,
            completedDoses: medicationToEdit?.completedDoses ?? []
        )
        
        if medicationToEdit != nil {
            store.updateMedication(med)
        } else {
            store.addMedication(med)
        }
        
        dismiss()
    }
}
