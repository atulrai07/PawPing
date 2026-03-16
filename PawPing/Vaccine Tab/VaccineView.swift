//
//  VaccineView.swift
//  PawPing
//
//  Created by Atul on 15/03/26.
//

import SwiftUI

struct VaccineView: View {
    var store: VaccineStore
    var profile: DogProfile

    var upcomingRecords: [VaccineRecord] {
        store.vaccineRecords.filter { $0.status == .upcoming }
    }

    var overdueRecords: [VaccineRecord] {
        store.vaccineRecords.filter { $0.status == .overdue }
    }

    var doneRecords: [VaccineRecord] {
        store.vaccineRecords.filter { $0.status == .done }
    }

    var summary: VaccineSummary {
        store.summary
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // Summary Card
                    VaccineSummaryCard(summary: summary)
                        .padding(.horizontal)
                    
                    // Upcoming Vaccines
                    if !upcomingRecords.isEmpty {
                        vaccineSection(title: "Upcoming Vaccines") {
                            VStack(spacing: 0) {
                                ForEach(Array(upcomingRecords.enumerated()), id: \.element.id) { index, record in
                                    VaccineRowView(record: record) {
                                        print("Mark as done: \(record.displayName)")
                                    }
                                    
                                    if index < upcomingRecords.count - 1 {
                                        Divider()
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.gray.opacity(0.1))
                            )
                        }
                    }
                    
                    // Overdue
                    if !overdueRecords.isEmpty {
                        vaccineSection(title: "Overdue") {
                            VStack(spacing: 0) {
                                ForEach(Array(overdueRecords.enumerated()), id: \.element.id) { index, record in
                                    VaccineRowView(record: record) {
                                        print("Mark as done: \(record.displayName)")
                                    }
                                    
                                    if index < overdueRecords.count - 1 {
                                        Divider()
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.gray.opacity(0.1))
                            )
                        }
                    }
                    
                    // Done
                    if !doneRecords.isEmpty {
                        vaccineSection(title: "Done") {
                            VStack(spacing: 0) {
                                ForEach(Array(doneRecords.enumerated()), id: \.element.id) { index, record in
                                    DoneVaccineRowView(record: record)
                                    
                                    if index < doneRecords.count - 1 {
                                        Divider()
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.gray.opacity(0.1))
                            )
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
            }
            .background(Color("baseBackground"))
            .navigationTitle("Vaccine")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(.gray.opacity(0.2))
                            .frame(width: 36, height: 36)
                            .overlay(
                                Image(profile.dogImage)
                                    .resizable()
                                    .scaledToFill()
                                    .clipShape(Circle())
                            )
                    }
                }
            }
        }
    }
    
    // Section builder
    private func vaccineSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.primary)
                .padding(.horizontal)
            
            content()
                .padding(.horizontal)
        }
    }
}

#Preview {
    VaccineView(store: VaccineStore(), profile: ActivityStore().dogProfile)
}
