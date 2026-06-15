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
    
    @State private var name = ""
    @State private var dosage = ""
    @State private var unit = MedicationUnit.tablet
    @State private var frequency = MedicationFrequency.onceDaily
    @State private var startDate = Date()
    @State private var hasEndDate = false
    @State private var endDate = Date().addingTimeInterval(86400 * 7)
    @State private var instructions = ""
    
    // Vet Clinic State
    @State private var vetName: String = ""
    @State private var vetAddress: String = ""
    @State private var vetPhone: String = ""
    @State private var vetLatitude: Double? = nil
    @State private var vetLongitude: Double? = nil
    @State private var showingVetSearch = false
    
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
            .navigationTitle("Add Medication")
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
            vetLongitude: vetLongitude
        )
        store.addMedication(med)
        dismiss()
    }
}
