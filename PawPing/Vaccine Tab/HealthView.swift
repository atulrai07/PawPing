//
//  VaccineView.swift → HealthView
//  PawPing
//
//  Created by Atul on 15/03/26.
//  Updated for Health system on 27/04/26.
//

import SwiftUI

struct HealthView: View {

    @Environment(HealthStore.self) var store
    @Environment(PetStore.self) var petStore

    @State private var showAddRecord = false
    @State private var showReportConfig = false

    // MARK: Derived collections

    var upcomingRecords: [HealthRecord] { store.healthRecords.filter { $0.status == .upcoming } }
    var overdueRecords:  [HealthRecord] { store.healthRecords.filter { $0.status == .overdue  } }
    var doneRecords:     [HealthRecord] { store.healthRecords.filter { $0.status == .done     } }
    
    var vaccines: [HealthRecord] { store.healthRecords.filter { $0.recordType == .vaccine } }
    var deworming: [HealthRecord] { store.healthRecords.filter { $0.recordType == .deworming } }

    var body: some View {
        NavigationStack {
            Group {
                if let petId = petStore.activePetId {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            // Summary Card
                            HealthSummaryCard(summary: store.summary)
                                .padding(.horizontal)

                            // Overdue / Actionable section
                            if !overdueRecords.isEmpty || !upcomingRecords.isEmpty {
                                healthSection(title: "Needs Attention") {
                                    recordList(overdueRecords + upcomingRecords) { record in
                                        HealthRecordRowView(record: record) {
                                            handleMarkAsDone(record)
                                        }
                                    }
                                }
                            }

                            // Sectioned list by type
                            healthSection(title: "Vaccinations") {
                                if vaccines.isEmpty {
                                    emptyState(message: "No vaccinations recorded yet")
                                } else {
                                    recordList(vaccines) { record in
                                        HealthRecordRowView(record: record)
                                    }
                                }
                            }

                            healthSection(title: "Deworming") {
                                if deworming.isEmpty {
                                    emptyState(message: "No deworming recorded yet")
                                } else {
                                    recordList(deworming) { record in
                                        HealthRecordRowView(record: record)
                                    }
                                }
                            }

                            // Export Button
                            ExportPassportButton {
                                showReportConfig = true
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 100)
                        }
                        .padding(.top, 10)
                    }
                    .background(Color("baseBackground"))
                    .task(id: petId) {
                        await store.fetchVaccines(for: petId)
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
                title: "Vaccine",
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
                } else {
                    Text("No pet selected")
                        .padding()
                }
            }
            .sheet(isPresented: $showReportConfig) {
                HealthReportSelectionView()
                    .environment(store)
                    .environment(petStore)
            }
        }
    }

    private func handleMarkAsDone(_ record: HealthRecord) {
        Task {
            if let petId = petStore.activePetId {
                await store.markAsDone(id: record.id, petId: petId)
            }
        }
    }

    // MARK: - Helpers

    private func healthSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color("baseColor"))
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
                if index < records.count - 1 { Divider() }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color("cardBackground"))
                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
        )
    }
    
    private func emptyState(message: String) -> some View {
        Text(message)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
                    .foregroundStyle(.secondary.opacity(0.4))
            )
    }
}

#Preview {
    HealthView()
        .environment(HealthStore())
        .environment(PetStore())
        .environment(AuthStore())
}
