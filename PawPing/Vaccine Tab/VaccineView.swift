//
//  VaccineView.swift
//  PawPing
//
//  Created by Atul on 15/03/26.
//
//  The Vaccine tab — shows a summary card + grouped lists of
//  upcoming, overdue, and completed vaccines.
//

import SwiftUI

// MARK: - VaccineView

struct VaccineView: View {

    // Passed in from ContentView — we don't own these
    var store: VaccineStore
    var profile: DogProfile

    // MARK: Derived collections
    // These are computed each render — no stale data possible.
    var upcomingRecords: [VaccineRecord] { store.vaccineRecords.filter { $0.status == .upcoming } }
    var overdueRecords:  [VaccineRecord] { store.vaccineRecords.filter { $0.status == .overdue  } }
    var doneRecords:     [VaccineRecord] { store.vaccineRecords.filter { $0.status == .done     } }
    var summary: VaccineSummary { store.summary }

    // MARK: Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {

                // Top card with done/upcoming/overdue counts
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
            } // VStack — main content
            .padding(.top, 10)
            .padding(.bottom, 80)
            .customNavigationScroll(title: "Vaccine", profileImage: profile.dogImage)
        } // NavigationStack
    }

    // MARK: - Helpers

    /// Wraps a section with a bold title.
    /// @ViewBuilder lets us pass SwiftUI views as a trailing closure.
    private func vaccineSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.pawSecondary)
                .padding(.horizontal)

            content()
                .padding(.horizontal)
        } // VStack — section
    }

    /// Renders a list of records inside a white rounded card,
    /// with dividers between each row. Uses generics so it works
    /// with both VaccineRowView and DoneVaccineRowView.
    private func recordList<R: Identifiable, Row: View>(
        _ records: [R],
        @ViewBuilder row: @escaping (R) -> Row
    ) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(records.enumerated()), id: \.offset) { index, record in
                row(record)
                if index < records.count - 1 { Divider() }
            }
        } // VStack — record list
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.pawNeutral))
    }
} // VaccineView

// MARK: - Preview

#Preview {
    VaccineView(store: VaccineStore(), profile: ActivityStore().dogProfile)
}
