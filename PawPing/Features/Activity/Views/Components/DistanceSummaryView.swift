//
//  DistanceSummaryView.swift
//  PawPing
//

import SwiftUI
import Charts

/// A detailed dashboard screen showing aggregated distance statistics (Week/Month) 
/// and a scrollable list of recent walk sessions.
struct DistanceSummaryView: View {
    // MARK: - Dependencies
    @Environment(\.dismiss) private var dismiss
    var store: ActivityStore
    
    // MARK: - State
    @State private var selectedRange = 0
    @State private var showCalendar = false
    private let ranges = ["Week", "Month"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // MARK: - Range Picker (Week vs Month)
                Picker("Range", selection: $selectedRange) {
                    ForEach(0..<ranges.count, id: \.self) { index in
                        Text(ranges[index]).tag(index)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 16)
                
                // MARK: - Summary Statistics
                VStack(alignment: .leading, spacing: 4) {
                    Text("TOTAL")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.secondary)
                    
                    // Dynamic distance label based on selection
                    Text(String(format: "%.2f km", selectedRange == 0 ? store.distanceSummary.totalWeekDistance : store.distanceSummary.totalMonthDistance))
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(Color("baseColor"))
                    
                    Text(selectedRange == 0 ? store.distanceSummary.weekRange : store.distanceSummary.monthName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                
                // MARK: - Interactive Bar Chart
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color("cardBackground"))
                        .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
                    
                    chartContent
                        .padding()
                }
                .frame(height: 280)
                .padding(.horizontal)
                
                // MARK: - Recent Activity List
                // (Removed list as per new requirements — access via calendar button in toolbar)
                Spacer(minLength: 40)
            }
        }
        .background(Color("baseBackground"))
        .navigationTitle("Distance Summary")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showCalendar = true
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color("secondaryText"))
                        .padding(8)
                        .background(Circle().fill(Color("secondaryCardBackground").opacity(0.5)))
                }
            }
        }
        .sheet(isPresented: $showCalendar) {
            WalkCalendarView()
                .environment(store)
        }
    }

    // MARK: - Subviews
    
    private var emptyStateView: some View {
        Text("No walks recorded yet.")
            .font(.system(size: 14))
            .foregroundStyle(.secondary)
            .padding(.horizontal)
    }

    /// Extracted row component for better readability and maintenance
    private struct WalkHistoryRow: View {
        let session: WalkSession
        
        var body: some View {
            HStack(spacing: 16) {
                // Activity Icon
                ZStack {
                    Circle()
                        .fill(Color("baseColor").opacity(0.1))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "figure.walk")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color("baseColor"))
                }
                
                // Session Metadata
                VStack(alignment: .leading, spacing: 2) {
                    Text(session.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.system(size: 14, weight: .semibold))
                    
                    Text("\(session.durationMinutes) min • \(String(format: "%.2f km", session.distanceMetres / 1000.0))")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.secondary.opacity(0.3))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color("cardBackground"))
                    .shadow(color: .black.opacity(0.02), radius: 5, x: 0, y: 2)
            )
        }
    }
    
    private var chartContent: some View {
        Chart {
            let data = selectedRange == 0 ? store.distanceSummary.weekData : store.distanceSummary.monthData
            
            ForEach(data) { item in
                BarMark(
                    x: .value("Date", selectedRange == 0 ? item.dayLabel : item.dayOfMonthLabel),
                    y: .value("Distance", item.distanceInKm)
                )
                .foregroundStyle(Color("baseColor"))
                .cornerRadius(4)
            }
            
            // Standardizing distance thresholds
            ForEach([0.75, 1.5, 2.25, 3.0], id: \.self) { threshold in
                RuleMark(y: .value("Threshold", threshold))
                    .lineStyle(StrokeStyle(lineWidth: 0.5, dash: [4]))
                    .foregroundStyle(.gray.opacity(0.35))
            }
        }
        .chartXAxis {
            if selectedRange == 0 {
                AxisMarks(values: .automatic) { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2]))
                        .foregroundStyle(.gray.opacity(0.2))
                    AxisValueLabel()
                        .font(.system(size: 12, weight: .medium))
                }
            } else {
                AxisMarks(values: ["1", "8", "15", "22", "30"]) { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2]))
                        .foregroundStyle(.gray.opacity(0.2))
                    AxisValueLabel()
                        .font(.system(size: 12, weight: .medium))
                }
            }
        }
        .chartYAxis {
            AxisMarks(values: [0, 0.75, 1.5, 2.25, 3.0]) { value in
                AxisValueLabel {
                    if let distance = value.as(Double.self) {
                        Text(distance == 0 ? "0" : String(format: "%.2fkm", distance))
                            .font(.system(size: 12, weight: .medium))
                    }
                }
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
            }
        }
        .chartYScale(domain: 0...3.3)
        .animation(.spring(duration: 0.5), value: selectedRange)
    }
}

#Preview {
    NavigationStack {
        DistanceSummaryView(store: ActivityStore())
    }
}
