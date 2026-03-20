//
//  VaccineView.swift
//  PawPing
//
//  Created by Atul on 15/03/26.
//

import SwiftUI

// MARK: - VaccineView

struct VaccineView: View {

    var store: VaccineStore
    var profile: DogProfile

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
                                print("Mark as done: \(record.displayName)")
                            }
                        }
                    }
                }

                // Overdue
                if !overdueRecords.isEmpty {
                    vaccineSection(title: "Overdue") {
                        recordList(overdueRecords) { record in
                            VaccineRowView(record: record) {
                                print("Mark as done: \(record.displayName)")
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
                    print("Export vaccine passport tapped")
                }
                .padding(.horizontal)
            }
            .padding(.top, 10)
            .padding(.bottom, 80)
            // ── One line replaces all scroll tracking + header boilerplate ──
            .customNavigationScroll(title: "Vaccine", profileImage: profile.dogImage)
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
                .foregroundStyle(.primary)
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
        .background(RoundedRectangle(cornerRadius: 16).fill(.gray.opacity(0.1)))
    }
}

// MARK: - Preview

#Preview {
    VaccineView(store: VaccineStore(), profile: ActivityStore().dogProfile)
}
