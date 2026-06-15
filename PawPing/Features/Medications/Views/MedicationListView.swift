//
//  MedicationListView.swift
//  PawPing
//

import SwiftUI

struct MedicationListView: View {
    @Environment(MedicationStore.self) var store
    @Environment(PetStore.self) var petStore
    @State private var showAddMedication = false
    
    var medications: [Medication] {
        guard let petId = petStore.activePetId else { return [] }
        return store.medications(for: petId).sorted { $0.startDate > $1.startDate }
    }
    
    var activeMedications: [Medication] { medications.filter { $0.status == .active } }
    var upcomingMedications: [Medication] { medications.filter { $0.status == .upcoming } }
    var completedMedications: [Medication] { medications.filter { $0.status == .completed } }
    
    var body: some View {
        Group {
            if medications.isEmpty {
                ContentUnavailableView("No Medications", systemImage: "pills", description: Text("Track your dog's medications here."))
            } else {
                List {
                    if !activeMedications.isEmpty {
                        Section("Active") {
                            ForEach(activeMedications) { med in
                                NavigationLink(destination: MedicationDetailView(medication: med)) {
                                    MedicationRow(medication: med)
                                }
                                .swipeActions(edge: .leading) {
                                    Button {
                                        store.logDose(for: med.id)
                                        // Trigger haptic feedback
                                        let generator = UINotificationFeedbackGenerator()
                                        generator.notificationOccurred(.success)
                                    } label: {
                                        Label("Log Dose", systemImage: "checkmark")
                                    }
                                    .tint(.green)
                                }
                            }
                        }
                    }
                    
                    if !upcomingMedications.isEmpty {
                        Section("Upcoming") {
                            ForEach(upcomingMedications) { med in
                                NavigationLink(destination: MedicationDetailView(medication: med)) {
                                    MedicationRow(medication: med)
                                }
                            }
                        }
                    }
                    
                    if !completedMedications.isEmpty {
                        Section("Completed") {
                            ForEach(completedMedications) { med in
                                NavigationLink(destination: MedicationDetailView(medication: med)) {
                                    MedicationRow(medication: med)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Medications")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddMedication = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddMedication) {
            AddMedicationView()
        }
    }
}

struct MedicationRow: View {
    let medication: Medication
    
    var body: some View {
        HStack {
            Image(systemName: "pills.fill")
                .foregroundStyle(.purple)
                .font(.title2)
                .frame(width: 40)
            
            VStack(alignment: .leading) {
                Text(medication.name)
                    .font(.headline)
                Text("\(medication.dosage) \(medication.unit.rawValue) • \(medication.frequency.rawValue)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
