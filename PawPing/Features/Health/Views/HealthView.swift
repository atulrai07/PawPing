//
//  HealthView.swift
//  PawPing
//
//  Created by Atul on 15/03/26.
//

import SwiftUI

struct HealthView: View {

    @Environment(HealthStore.self) var store
    @Environment(PetStore.self) var petStore

    @State private var showAddRecord = false
    @State private var showReportConfig = false
    @State private var selectedType: HealthRecordType = .vaccine
    @State private var recordToMarkDone: HealthRecord?
    @State private var showDoneConfirmation = false

    // MARK: - Derived Logic

    /// Returns records of the selected type (Vaccine or Deworming)
    private var filteredRecords: [HealthRecord] {
        store.healthRecords.filter { $0.recordType == selectedType }
    }

    /// Overdue records of the selected type
    var overdueRecords: [HealthRecord] { 
        filteredRecords.filter { $0.status == .overdue }
            .sorted(by: { ($0.nextDoseDate ?? Date()) < ($1.nextDoseDate ?? Date()) })
    }
    
    /// Upcoming records within the next 30 days
    var upcomingRecords: [HealthRecord] { 
        let thirtyDaysFromNow = Calendar.current.date(byAdding: .day, value: 30, to: Date())!
        
        return filteredRecords.filter { 
            $0.status == .upcoming && 
            ($0.nextDoseDate ?? Date.distantFuture) <= thirtyDaysFromNow 
        }
        .sorted(by: { ($0.nextDoseDate ?? Date()) < ($1.nextDoseDate ?? Date()) })
    }
    
    /// Completed records OR future records beyond 30 days
    var historyRecords: [HealthRecord] { 
        let thirtyDaysFromNow = Calendar.current.date(byAdding: .day, value: 30, to: Date())!
        
        return filteredRecords.filter { 
            $0.status == .done || 
            (($0.nextDoseDate ?? Date.distantPast) > thirtyDaysFromNow)
        }
        .sorted(by: { 
            // Sort by most recently given dose first
            $0.dateGiven > $1.dateGiven 
        })
    }

    var body: some View {
        NavigationStack {
            Group {
                if let petId = petStore.activePetId {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            // MARK: - Type Picker
                            Picker("Type", selection: $selectedType) {
                                ForEach(HealthRecordType.allCases, id: \.self) { type in
                                    Text(type.displayName).tag(type)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal)
                            .padding(.top, 16)

                            // MARK: - Summary Statistics
                            HealthSummaryCard(summary: HealthSummary(from: filteredRecords))
                                .padding(.horizontal)

                            // MARK: - Overdue Section
                            if !overdueRecords.isEmpty {
                                healthSection(title: " Needs Attention", color: .red) {
                                    recordList(overdueRecords) { record in
                                        HealthRecordRowView(record: record) {
                                            handleMarkAsDone(record)
                                        }
                                    }
                                }
                            }

                            // MARK: - Upcoming (Within 30 Days)
                            healthSection(title: "⏳ Upcoming", color: Color("baseColor")) {
                                if upcomingRecords.isEmpty {
                                    emptyState(message: "Nothing due in the next 30 days")
                                } else {
                                    recordList(upcomingRecords) { record in
                                        HealthRecordRowView(record: record) {
                                            handleMarkAsDone(record)
                                        }
                                    }
                                }
                            }

                            // MARK: - History (Done or Far-Future)
                            healthSection(title: " History", color: .gray) {
                                if historyRecords.isEmpty {
                                    emptyState(message: "No records found")
                                } else {
                                    recordList(historyRecords) { record in
                                        HealthRecordRowView(record: record)
                                            .opacity(0.7)
                                    }
                                }
                            }

                            // MARK: - Export
                            ExportPassportButton {
                                showReportConfig = true
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 100)
                        }
                        .padding(.top, 10)
                    }
                    .background(Color.pawBackground)
                    .task(id: petId) {
                        await store.fetchHealthRecords(for: petId)
                    }
                } else {
                    ContentUnavailableView(
                        "No Pet Selected",
                        systemImage: "dog.fill",
                        description: Text("Please add a pet to track their health records.")
                    )
                }
            }
            .customNavigationScroll(
                title: "Health",
                petStore: petStore,
                onAddTap: {
                    if petStore.activePetId != nil {
                        showAddRecord = true
                    }
                }
            )
            .sheet(isPresented: $showAddRecord) {
                if let petId = petStore.activePetId {
                    AddHealthRecordView(petId: petId)
                }
            }
            .sheet(isPresented: $showReportConfig) {
                NavigationStack {
                    HealthReportConfigView()
                        .environment(petStore)
                        .environment(store)
                }
            }
            .alert("Mark as Done?", isPresented: $showDoneConfirmation) {
                Button("Cancel", role: .cancel) { recordToMarkDone = nil }
                Button("Confirm") {
                    if let record = recordToMarkDone {
                        performMarkAsDone(record)
                    }
                }
            } message: {
                if let record = recordToMarkDone {
                    Text("Are you sure you want to mark '\(record.name)' as completed? This will update your pet's health history.")
                }
            }
        }
    }

    private func handleMarkAsDone(_ record: HealthRecord) {
        recordToMarkDone = record
        showDoneConfirmation = true
    }

    private func performMarkAsDone(_ record: HealthRecord) {
        Task {
            if let petId = petStore.activePetId {
                await store.markAsDone(id: record.id, petId: petId)
            }
        }
    }

    // MARK: - Helpers

    private func healthSection<Content: View>(
        title: String,
        color: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(color)
                .padding(.horizontal)

            content()
                .padding(.horizontal)
        }
    }

    private func recordList<R: Identifiable, Row: View>(
        _ records: [R],
        @ViewBuilder row: @escaping (R) -> Row
    ) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(records.enumerated()), id: \.offset) { index, record in
                row(record)
                if index < records.count - 1 { 
                    Divider()
                        .padding(.horizontal)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color("cardBackground"))
                .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 4)
        )
    }
    
    private func emptyState(message: String) -> some View {
        Text(message)
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .foregroundStyle(.secondary.opacity(0.3))
            )
    }
}

#Preview {
    HealthView()
        .environment(HealthStore())
        .environment(PetStore())
        .environment(AuthStore())
}
