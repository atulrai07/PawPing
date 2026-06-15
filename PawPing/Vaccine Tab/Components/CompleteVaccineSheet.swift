//
//  CompleteVaccineSheet.swift
//  PawPing
//

import SwiftUI
import MapKit

struct CompleteVaccineSheet: View {
    @Environment(HealthStore.self) var healthStore
    @Environment(PetStore.self) var petStore
    @Environment(\.dismiss) private var dismiss
    
    let originalRecord: HealthRecord
    
    @State private var dateGiven: Date = Date()
    @State private var hasNextDose: Bool = true
    @State private var frequency: DoseFrequency = .annually
    @State private var nextDoseDate: Date? = nil
    
    // Vet Clinic State
    @State private var vetName: String = ""
    @State private var vetAddress: String = ""
    @State private var vetPhone: String = ""
    @State private var vetLatitude: Double? = nil
    @State private var vetLongitude: Double? = nil
    
    @State private var showingVetSearch = false
    @State private var showEarlyAlert = false
    @State private var isSaving = false
    
    init(originalRecord: HealthRecord) {
        self.originalRecord = originalRecord
        
        // Default to original record's vet info if present
        _vetName = State(initialValue: originalRecord.vetName ?? "")
        _vetAddress = State(initialValue: originalRecord.vetAddress ?? "")
        _vetPhone = State(initialValue: originalRecord.vetPhone ?? "")
        _vetLatitude = State(initialValue: originalRecord.vetLatitude)
        _vetLongitude = State(initialValue: originalRecord.vetLongitude)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text(originalRecord.name)
                            .foregroundStyle(.secondary)
                    }
                    
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
            }
            .navigationTitle("Complete Vaccine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        handleSaveTap()
                    }
                    .disabled(isSaving)
                    .fontWeight(.bold)
                }
            }
            .sheet(isPresented: $showingVetSearch) {
                VetSearchView { mapItem in
                    handleVetSelection(mapItem)
                }
            }
            .alert("Early Vaccination", isPresented: $showEarlyAlert) {
                Button("Cancel", role: .cancel) { }
                Button("OK") {
                    saveCompletion()
                }
            } message: {
                if let designatedDate = originalRecord.nextDoseDate {
                    let formattedDate = designatedDate.formatted(date: .long, time: .omitted)
                    Text("The Designated date for this Vaccine was \(formattedDate) but you have vaccinated early, do you want to log this?")
                } else {
                    Text("You are vaccinating early. Do you want to log this?")
                }
            }
            .overlay {
                if isSaving {
                    ProgressView("Saving...")
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .onAppear {
                // Initialize next dose date based on current frequency & today
                updateNextDoseDate()
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
            nextDoseDate = Calendar.current.date(byAdding: .year, value: 1, to: dateGiven)
        }
    }
    
    private func handleSaveTap() {
        if let designatedDate = originalRecord.nextDoseDate,
           Calendar.current.startOfDay(for: dateGiven) < Calendar.current.startOfDay(for: designatedDate) {
            showEarlyAlert = true
        } else {
            saveCompletion()
        }
    }
    
    private func saveCompletion() {
        isSaving = true
        
        // 1. Update the original record to completed
        var updatedRecord = originalRecord
        updatedRecord.isCompleted = true
        updatedRecord.dateGiven = dateGiven
        updatedRecord.nextDoseDate = hasNextDose ? nextDoseDate : nil
        updatedRecord.vetName = vetName.isEmpty ? nil : vetName
        updatedRecord.vetAddress = vetAddress.isEmpty ? nil : vetAddress
        updatedRecord.vetPhone = vetPhone.isEmpty ? nil : vetPhone
        updatedRecord.vetLatitude = vetLatitude
        updatedRecord.vetLongitude = vetLongitude
        
        Task {
            // Update in Supabase
            await healthStore.updateHealthRecord(updatedRecord)
            
            // 2. If reminder is toggled on, create a new upcoming record
            if hasNextDose, let nextDate = nextDoseDate {
                let nextRecord = HealthRecord(
                    id: UUID(),
                    petId: originalRecord.petId,
                    type: originalRecord.type,
                    name: originalRecord.name,
                    dateGiven: dateGiven,
                    nextDoseDate: nextDate,
                    notes: "",
                    isCompleted: false,
                    vetName: nil,
                    vetAddress: nil,
                    vetPhone: nil,
                    vetLatitude: nil,
                    vetLongitude: nil
                )
                await healthStore.addHealthRecord(nextRecord)
            } else {
                // If we didn't add a new record (which triggers refetch), manually trigger refetch to update UI status to Done.
                await healthStore.fetchVaccines(for: originalRecord.petId)
            }
            
            isSaving = false
            dismiss()
        }
    }
}
