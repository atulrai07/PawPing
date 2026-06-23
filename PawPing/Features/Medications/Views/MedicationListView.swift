//
//  MedicationListView.swift
//  PawPing
//

import SwiftUI

struct MedicationListView: View {
    @Environment(MedicationStore.self) var store
    @Environment(PetStore.self) var petStore
    @State private var showAddMedication = false
    @State private var showLogDoseSheet = false
    @State private var selectedMedication: Medication? = nil
    @State private var selectedSlot: Medication.DoseSlot? = nil
    @State private var timeGiven = Date()
    
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
                    .background(
                        LinearGradient(colors: [.bgWarmTop, .bgWarmBottom], startPoint: .topLeading, endPoint: .bottomTrailing)
                            .ignoresSafeArea()
                    )
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {
                        if !activeMedications.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Active")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.gray)
                                    .padding(.horizontal, 20)
                                
                                VStack(spacing: 0) {
                                    ForEach(activeMedications) { med in
                                        NavigationLink(destination: MedicationDetailView(medication: med)) {
                                            MedicationRow(medication: med)
                                        }
                                        .buttonStyle(.plain)
                                        
                                        if med.id != activeMedications.last?.id {
                                            Divider()
                                                .padding(.leading, 56)
                                                .padding(.vertical, 8)
                                        }
                                    }
                                }
                                .padding(16)
                                .background(Color.cardIvory)
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        if !upcomingMedications.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Upcoming")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.gray)
                                    .padding(.horizontal, 20)
                                
                                VStack(spacing: 0) {
                                    ForEach(upcomingMedications) { med in
                                        NavigationLink(destination: MedicationDetailView(medication: med)) {
                                            MedicationRow(medication: med)
                                        }
                                        .buttonStyle(.plain)
                                        
                                        if med.id != upcomingMedications.last?.id {
                                            Divider()
                                                .padding(.leading, 56)
                                                .padding(.vertical, 8)
                                        }
                                    }
                                }
                                .padding(16)
                                .background(Color.cardIvory)
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        if !completedMedications.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Completed")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.gray)
                                    .padding(.horizontal, 20)
                                
                                VStack(spacing: 0) {
                                    ForEach(completedMedications) { med in
                                        NavigationLink(destination: MedicationDetailView(medication: med)) {
                                            MedicationRow(medication: med)
                                        }
                                        .buttonStyle(.plain)
                                        
                                        if med.id != completedMedications.last?.id {
                                            Divider()
                                                .padding(.leading, 56)
                                                .padding(.vertical, 8)
                                        }
                                    }
                                }
                                .padding(16)
                                .background(Color.cardIvory)
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
                .background(
                    LinearGradient(colors: [.bgWarmTop, .bgWarmBottom], startPoint: .topLeading, endPoint: .bottomTrailing)
                        .ignoresSafeArea()
                )
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
        .sheet(isPresented: $showLogDoseSheet) {
            if let med = selectedMedication, let slot = selectedSlot {
                NavigationStack {
                    ScrollView {
                        VStack(spacing: 24) {
                            VStack(spacing: 8) {
                                Image(systemName: "pills.fill")
                                    .font(.system(size: 48))
                                    .foregroundStyle(Color("baseColor"))
                                    .padding()
                                    .background(Color("baseColor").opacity(0.1))
                                    .clipShape(Circle())
                                
                                Text("Log dose for \(med.name) (\(med.dosage) \(med.unit.rawValue)) scheduled for \(slot.time).")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.top, 16)
                            
                            DatePicker("Time Given", selection: $timeGiven, displayedComponents: .hourAndMinute)
                                .datePickerStyle(.wheel)
                                .labelsHidden()
                        }
                    }
                    .navigationTitle("Log Dose")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                showLogDoseSheet = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                store.logDose(for: med.id, date: timeGiven)
                                
                                // Trigger haptic feedback
                                let generator = UINotificationFeedbackGenerator()
                                generator.notificationOccurred(.success)
                                
                                showLogDoseSheet = false
                            }
                            .bold()
                        }
                    }
                }
                .presentationDetents([.medium])
            }
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
            
            VStack(alignment: .leading, spacing: 4) {
                Text(medication.name)
                    .font(.headline)
                Text("\(medication.dosage) \(medication.unit.rawValue) • \(medication.frequency.rawValue)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                // Show today's slots as indicators if active today
                if medication.isActive(on: Date()) {
                    let slots = medication.doseSlots(for: Date())
                    if !slots.isEmpty {
                        HStack(spacing: 6) {
                            ForEach(slots) { slot in
                                if slot.time == "As Needed" {
                                    EmptyView()
                                } else {
                                    HStack(spacing: 2) {
                                        Image(systemName: slot.completedDate != nil ? "checkmark.circle.fill" : "circle")
                                            .font(.caption2)
                                            .foregroundStyle(slot.completedDate != nil ? .green : .secondary)
                                        Text(slot.time)
                                            .font(.system(size: 10, weight: .semibold))
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(
                                        Capsule()
                                            .fill(slot.completedDate != nil ? Color.green.opacity(0.15) : Color.gray.opacity(0.1))
                                    )
                                }
                            }
                        }
                        .padding(.top, 2)
                    }
                }
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
