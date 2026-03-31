//
//  AddVaccineFlowView.swift
//  PawPing
//
// Created by SidMoon on 28/03/26.
//
//  Multi-step sheet for adding a new vaccination record.
//  Step 1: Vaccine details (name, date, time, frequency).
//  Step 2: Clinic information (manual entry or select from vet care).
//

import SwiftUI

// MARK: - Frequency Option

enum VaccineFrequency: String, CaseIterable, Identifiable {
    case none = "Select"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case quarterly = "Every 3 Months"
    case biannually = "Every 6 Months"
    case annually = "Annually"

    var id: String { rawValue }
}

// MARK: - Add Vaccine Flow View

struct AddVaccineFlowView: View {

    @Environment(VaccineStore.self) var vaccineStore
    @Environment(CareStore.self) var careStore
    @Environment(ActivityStore.self) var activityStore

    @Environment(\.dismiss) private var dismiss

    // Navigation
    @State private var currentStep: Int = 1

    // Step 1 fields
    @State private var selectedVaccineName: VaccineName? = nil
    @State private var dateGiven: Date = Date()
    @State private var timeGiven: Date = Date()
    @State private var selectedFrequency: VaccineFrequency = .none

    // Step 2 fields
    @State private var clinicInputMode: ClinicInputMode = .manual
    @State private var vetName: String = ""
    @State private var clinicName: String = ""
    @State private var address: String = ""
    @State private var phoneNumber: String = ""
    @State private var notes: String = ""
    @State private var selectedVetClinic: CareLocation? = nil
    @State private var showingVetSelection = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if currentStep == 1 {
                    vaccineRecordStep
                } else {
                    clinicRecordStep
                }
            }
            .background(Color("baseBackground"))
            .navigationTitle(currentStep == 1 ? "Add Vaccine Record" : "Add Clinic Record")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationDestination(isPresented: $showingVetSelection) {
                VetCareSelectionView(onSelect: handleVetSelection)
            }
        }
    }

    // MARK: - Step 1: Vaccine Record

    private var vaccineRecordStep: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // Syringe icon
                    HStack {
                        Spacer()
                        Image(systemName: "syringe.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(Color("baseColor"))
                        Spacer()
                    }
                    .padding(.top, 16)

                    // Section header
                    Text("Enter Vaccine Record")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(.secondary)

                    // Form fields
                    VStack(spacing: 0) {
                        // Vaccine Name
                        HStack {
                            Text("Vaccine Name")
                                .font(.system(size: 16, weight: .regular))

                            Spacer()

                            Menu {
                                Button("Select") {
                                    selectedVaccineName = nil
                                }
                                ForEach(VaccineName.allStandard, id: \.displayName) { vaccine in
                                    Button(vaccine.displayName) {
                                        selectedVaccineName = vaccine
                                    }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text(selectedVaccineName?.displayName ?? "Select")
                                        .font(.system(size: 15))
                                        .foregroundStyle(.secondary)
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding(.vertical, 14)

                        Divider()

                        // Date Given
                        HStack {
                            Text("Date Given")
                                .font(.system(size: 16, weight: .regular))

                            Spacer()

                            DatePicker("", selection: $dateGiven, in: ...Date(), displayedComponents: .date)
                                .labelsHidden()
                                .datePickerStyle(.compact)
                                .fixedSize()
                        }
                        .padding(.vertical, 14)

                        Divider()

                        // Time
                        HStack {
                            Text("Time")
                                .font(.system(size: 16, weight: .regular))

                            Spacer()

                            DatePicker("", selection: $timeGiven, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .datePickerStyle(.compact)
                                .fixedSize()
                        }
                        .padding(.vertical, 14)
                    }
                    .padding(.horizontal, 16)
                    .background(Color("cardBackground"))
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    // Duration section
                    Text("Duration")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(.secondary)

                    VStack(spacing: 0) {
                        // Frequency
                        HStack {
                            Text("Frequency")
                                .font(.system(size: 16, weight: .regular))

                            Spacer()

                            Menu {
                                ForEach(VaccineFrequency.allCases) { frequency in
                                    Button(frequency.rawValue) {
                                        selectedFrequency = frequency
                                    }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text(selectedFrequency.rawValue)
                                        .font(.system(size: 15))
                                        .foregroundStyle(.secondary)
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding(.vertical, 14)
                    }
                    .padding(.horizontal, 16)
                    .background(Color("cardBackground"))
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    // Hint text
                    Text("Set how often this vaccine needs to be renewed.")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
            }

            // Next button
            Button {
                withAnimation {
                    currentStep = 2
                }
            } label: {
                Text("Next")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color("baseColor"))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }

    // MARK: - Step 2: Clinic Record

    private var clinicRecordStep: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // Syringe icon
                    HStack {
                        Spacer()
                        Image(systemName: "syringe.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(Color("baseColor"))
                        Spacer()
                    }
                    .padding(.top, 16)

                    // Section header
                    Text("Clinic Information")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(.secondary)

                    // Segmented control
                    clinicModeSelector

                    // Content based on mode
                    if clinicInputMode == .manual {
                        manualClinicForm
                    } else {
                        vetCareSelectionForm
                    }
                }
                .padding(.horizontal)
            }

            // Save button
            Button {
                saveVaccineRecord()
                dismiss()
            } label: {
                Text("Save")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color("baseColor"))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }

    // MARK: - Clinic Mode Selector

    private var clinicModeSelector: some View {
        HStack(spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    clinicInputMode = .manual
                }
            } label: {
                Text("Enter Manually")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(clinicInputMode == .manual ? .white : Color("baseColor"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(clinicInputMode == .manual ? Color("baseColor") : Color.clear)
                    )
            }

            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    clinicInputMode = .vetCenter
                }
            } label: {
                Text("Select From Vet care")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(clinicInputMode == .vetCenter ? .white : Color("baseColor"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(clinicInputMode == .vetCenter ? Color("baseColor") : Color.clear)
                    )
            }
        }
        .padding(4)
        .background(Color("baseColor").opacity(0.12))
        .clipShape(Capsule())
    }

    // MARK: - Manual Clinic Form

    private var manualClinicForm: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Vet Name
            VStack(alignment: .leading, spacing: 6) {
                Text("Vet Name")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)

                TextField("Enter Vet Name", text: $vetName)
                    .font(.system(size: 16))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 14)
                    .background(Color("cardBackground"))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            // Clinic Name
            VStack(alignment: .leading, spacing: 6) {
                Text("Clinic Name")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)

                TextField("Enter Clinic Name", text: $clinicName)
                    .font(.system(size: 16))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 14)
                    .background(Color("cardBackground"))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            // Address
            VStack(alignment: .leading, spacing: 6) {
                Text("Address")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)

                TextField("Enter Address", text: $address)
                    .font(.system(size: 16))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 14)
                    .background(Color("cardBackground"))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            // Phone Number
            VStack(alignment: .leading, spacing: 6) {
                Text("Phone Number")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)

                TextField("Enter Phone Number", text: $phoneNumber)
                    .font(.system(size: 16))
                    .keyboardType(.phonePad)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 14)
                    .background(Color("cardBackground"))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            // Notes
            VStack(alignment: .leading, spacing: 6) {
                Text("Notes")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)

                TextField("Add any additional notes here...", text: $notes, axis: .vertical)
                    .font(.system(size: 16))
                    .lineLimit(3, reservesSpace: true)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 14)
                    .background(Color("cardBackground"))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - Vet Care Selection Form

    private var vetCareSelectionForm: some View {
        VStack(spacing: 20) {
            // Illustration placeholder
            VStack(spacing: 12) {
                Image(systemName: "hand.point.up.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary.opacity(0.6))
                    .padding(.top, 24)

                Text("Select your clinic from our vet care\nlist to automatically add clinics")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                // Select Vet Clinic button
                Button {
                    showingVetSelection = true
                } label: {
                    Text("Select Vet Clinic")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color("baseColor"))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .stroke(Color("baseColor"), lineWidth: 1.5)
                        )
                }
                .padding(.bottom, 8)
            }

            // Notes
            VStack(alignment: .leading, spacing: 6) {
                Text("Notes")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)

                TextField("Add any additional notes here...", text: $notes, axis: .vertical)
                    .font(.system(size: 16))
                    .lineLimit(3, reservesSpace: true)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 14)
                    .background(Color("cardBackground"))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - Save Logic

    private func saveVaccineRecord() {
        // Build the clinic info
        var clinicInfo: ClinicInfo? = nil

        if clinicInputMode == .manual {
            if !clinicName.isEmpty {
                clinicInfo = ClinicInfo(
                    id: UUID(),
                    vetName: vetName,
                    clinicName: clinicName,
                    address: address.isEmpty ? nil : address,
                    phoneNumber: phoneNumber.isEmpty ? nil : phoneNumber,
                    linkedVetId: selectedVetClinic?.id
                )
            }
        } else {
            if let selectedClinic = selectedVetClinic {
                clinicInfo = ClinicInfo(
                    id: UUID(),
                    vetName: "",
                    clinicName: selectedClinic.name,
                    address: selectedClinic.address,
                    phoneNumber: selectedClinic.contactNumber,
                    linkedVetId: selectedClinic.id
                )
            }
        }

        // Calculate next dose date based on frequency
        var nextDoseDate: Date? = nil
        let calendar = Calendar.current
        switch selectedFrequency {
        case .none:
            nextDoseDate = nil
        case .weekly:
            nextDoseDate = calendar.date(byAdding: .weekOfYear, value: 1, to: dateGiven)
        case .monthly:
            nextDoseDate = calendar.date(byAdding: .month, value: 1, to: dateGiven)
        case .quarterly:
            nextDoseDate = calendar.date(byAdding: .month, value: 3, to: dateGiven)
        case .biannually:
            nextDoseDate = calendar.date(byAdding: .month, value: 6, to: dateGiven)
        case .annually:
            nextDoseDate = calendar.date(byAdding: .year, value: 1, to: dateGiven)
        }

        // Create the record
        let newRecord = VaccineRecord(
            id: UUID(),
            dogId: UUID(),
            vaccineName: selectedVaccineName ?? .other("Unknown"),
            dateGiven: dateGiven,
            clinicInfo: clinicInfo,
            nextDoseDate: nextDoseDate,
            notes: notes
        )

        vaccineStore.addRecord(newRecord)
    }

    // MARK: - Handlers

    private func handleVetSelection(_ clinic: CareLocation) {
        selectedVetClinic = clinic
        vetName = ""
        clinicName = clinic.name
        address = clinic.address ?? ""
        phoneNumber = clinic.contactNumber ?? ""
        
        // Return to manual view to showcase populated data
        withAnimation {
            clinicInputMode = .manual
        }
    }
}

// MARK: - Preview

#Preview {
    AddVaccineFlowView()
        .environment(VaccineStore())
        .environment(CareStore())
        .environment(ActivityStore())
}
