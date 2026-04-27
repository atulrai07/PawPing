//
//  VaccineView.swift
//  PawPing
//
//  Created by Atul on 15/03/26.
//

import SwiftUI

// MARK: - VaccineView

struct VaccineView: View {

    @Environment(VaccineStore.self) var store
    @Environment(PetStore.self) var petStore
    @Environment(CareStore.self) var careStore

    @State private var showAddVaccine = false
    @State private var showReportConfig = false

    // MARK: Derived collections

    var upcomingRecords: [VaccineRecord] { store.vaccineRecords.filter { $0.status == .upcoming } }
    var overdueRecords:  [VaccineRecord] { store.vaccineRecords.filter { $0.status == .overdue  } }
    var doneRecords:     [VaccineRecord] { store.vaccineRecords.filter { $0.status == .done     } }
    var summary: VaccineSummary { store.summary }

    // MARK: Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {

                // Summary Card
                VaccineSummaryCard(summary: summary)
                    .padding(.horizontal)

                // Upcoming Vaccines
                if !upcomingRecords.isEmpty {
                    vaccineSection(title: "Upcoming Vaccines") {
                        recordList(upcomingRecords) { record in
                            VaccineRowView(record: record) {
                                withAnimation {
                                    store.markAsDone(id: record.id)
                                }
                            }
                        }
                    }
                }

                // Overdue
                if !overdueRecords.isEmpty {
                    vaccineSection(title: "Overdue") {
                        recordList(overdueRecords) { record in
                            VaccineRowView(record: record) {
                                withAnimation {
                                    store.markAsDone(id: record.id)
                                }
                            }
                        }
                    }
                }

                // Done
                if !doneRecords.isEmpty {
                    vaccineSection(title: "Done") {
                        recordList(doneRecords) { record in
                            DoneVaccineRowView(record: record)
                        }
                    }
                }

                // Export Button
                ExportPassportButton {
                    showReportConfig = true
                }
                .padding(.horizontal)
            }
            .padding(.top, 10)
            .padding(.bottom, 80)
            .customNavigationScroll(
                title: "Vaccine",
                petStore: petStore,
                onAddTap: { showAddVaccine = true }
            )
            .navigationDestination(isPresented: $showReportConfig) {
                VaccineReportConfigView()
                    .environment(petStore)
                    .environment(store)
            }
            .sheet(isPresented: $showAddVaccine) {
                AddVaccineFlowView()
            }
        }
    }

    // MARK: - Helpers

    /// Titled section wrapper.
    private func vaccineSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color("baseColor"))
                .padding(.horizontal)

            content()
                .padding(.horizontal)
        }
    }

    /// Card-style list of records with dividers between rows.
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
        .padding(.vertical, 6)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color("cardBackground")))
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        VaccineView()
            .environment(VaccineStore())
            .environment(PetStore())
            .environment(CareStore())
            .environmentObject(AuthStore())
            .environmentObject(AppState())
    }
}
