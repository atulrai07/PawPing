//
//  WeightTrackerView.swift
//  PawPing
//

import SwiftUI
import Charts

struct WeightTrackerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(WeightStore.self) var weightStore
    @Environment(PetStore.self) var petStore
    
    @State private var showLogSheet = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if weightStore.records.isEmpty {
                    emptyState
                } else {
                    chartSection
                    summarySection
                }
                
                Spacer(minLength: 40)
                
                Text("Body condition is self-reported. Ask your vet for a clinical assessment.")
                    .font(.system(size: 11))
                    .foregroundStyle(Color("secondaryText"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .padding(.top, 24)
        }
        .background(Color("baseBackground"))
        .customNavigationScroll(
            title: "Weight Tracker",
            petStore: petStore
        )
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showLogSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color("baseColor"))
                }
            }
        }
        .sheet(isPresented: $showLogSheet) {
            LogWeightSheet()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "scalemass.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color("baseColor").opacity(0.3))
            
            Text("No Weight Records")
                .font(.system(size: 20, weight: .semibold))
            
            Text("Log your first weight check-in to start tracking trends.")
                .font(.system(size: 14))
                .foregroundStyle(Color("secondaryText"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button {
                showLogSheet = true
            } label: {
                Text("Log Weight")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color("baseColor"))
                    .clipShape(Capsule())
            }
            .padding(.top, 8)
        }
        .padding(.top, 60)
    }

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Weight Trend")
                .font(.system(size: 18, weight: .bold))
                .padding(.horizontal)

            Chart {
                ForEach(weightStore.records) { record in
                    LineMark(
                        x: .value("Date", record.date),
                        y: .value("Weight", record.weightKg)
                    )
                    .foregroundStyle(Color.gray.opacity(0.4))
                    .interpolationMethod(.monotone)

                    PointMark(
                        x: .value("Date", record.date),
                        y: .value("Weight", record.weightKg)
                    )
                    .foregroundStyle(color(for: record.bodyCondition))
                    .symbolSize(100)
                }
            }
            .chartYScale(domain: .automatic(includesZero: false))
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 7)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month().day())
                }
            }
            .frame(height: 240)
            .padding()
            .background(Color("cardBackground"))
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .padding(.horizontal)
        }
    }

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Latest Log")
                .font(.system(size: 18, weight: .bold))
                .padding(.horizontal)

            if let latest = weightStore.latest {
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(latest.weightKg, specifier: "%.1f") kg")
                            .font(.system(size: 28, weight: .bold))
                        Text(timeAgo(from: latest.date))
                            .font(.system(size: 13))
                            .foregroundStyle(Color("secondaryText"))
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 6) {
                        Text("Body Condition")
                            .font(.system(size: 13))
                            .foregroundStyle(Color("secondaryText"))
                        
                        Text(latest.bodyConditionLabel)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(color(for: latest.bodyCondition))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(color(for: latest.bodyCondition).opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
                .padding(20)
                .background(Color("cardBackground"))
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal)
            }
        }
    }

    private func color(for condition: BodyCondition) -> Color {
        switch condition {
        case .underweight: return .red
        case .ideal: return .green
        case .overweight: return .orange
        }
    }

    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
