//
//  VaccineView.swift
//  PawPing
//

import SwiftUI

struct VaccineView: View {

    var store: VaccineStore
    var activityStore: ActivityStore

    // MARK: Derived collections
    var upcomingRecords: [VaccineRecord] { store.vaccineRecords.filter { $0.status == .upcoming } }
    var overdueRecords:  [VaccineRecord] { store.vaccineRecords.filter { $0.status == .overdue  } }
    var doneRecords:     [VaccineRecord] { store.vaccineRecords.filter { $0.status == .done     } }
    var summary: VaccineSummary { store.summary }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {

                VaccineSummaryCard(summary: summary)
                    .padding(.horizontal)

                if !upcomingRecords.isEmpty {
                    vaccineSection(title: "Upcoming Vaccines") {
                        recordList(upcomingRecords) { record in
                            VaccineRowView(record: record)
                        }
                    }
                }

                if !overdueRecords.isEmpty {
                    vaccineSection(title: "Overdue") {
                        recordList(overdueRecords) { record in
                            VaccineRowView(record: record)
                        }
                    }
                }

                if !doneRecords.isEmpty {
                    vaccineSection(title: "Done") {
                        recordList(doneRecords) { record in
                            DoneVaccineRowView(record: record)
                        }
                    }
                }

                ExportPassportButton {
                    print("Export tapped")
                }
                .padding(.horizontal)
            }
            .padding(.top, 10)
            .padding(.bottom, 80)
            .navigationTitle("Vaccine")   // ✅ SIMPLE FIX
        }
    }

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
        .padding(.vertical, 6)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.pawNeutral))
    }
}

#Preview {
    NavigationStack {
        VaccineView(store: VaccineStore(), activityStore: ActivityStore())
    }
}
