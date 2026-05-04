//
// DistanceSummaryView.swift
// Pawping
//
//Created by Atul on 28/03/26
import SwiftUI
import Charts

struct DistanceSummaryView: View {
    @Environment(\.dismiss) private var dismiss
    var store: ActivityStore
    
    @State private var selectedRange = 0
    @State private var showCalendar = false
    
    private let ranges = ["Week", "Month"]
    
    var body: some View {
        VStack(spacing: 24) {
            // MARK: - Range Picker
            Picker("Range", selection: $selectedRange) {
                ForEach(0..<ranges.count, id: \.self) { index in
                    Text(ranges[index]).tag(index)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.top, 8)
            
            // MARK: - Summary Statistics
            VStack(alignment: .leading, spacing: 4) {
                Text("TOTAL")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.primary)
                
                Text(String(format: "%.2f km", selectedRange == 0 ? store.distanceSummary.totalWeekDistance : store.distanceSummary.totalMonthDistance))
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color("baseColor"))
                
                Text(selectedRange == 0 ? store.distanceSummary.weekRange : store.distanceSummary.monthName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color("secondaryText"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            
            // MARK: - Chart Card
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color("cardBackground"))
                    .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
                
                chartContent
                    .padding()
            }
            .frame(height: 280)
            .padding(.horizontal)
            
            Spacer()
        }
        .background(Color("baseBackground"))
        .navigationTitle("Distance")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showCalendar = true
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color("baseColor"))
                }
            }
        }
        .sheet(isPresented: $showCalendar) {
            WalkCalendarView(store: store)
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
            
            // Grid lines as shown in screenshot
            RuleMark(y: .value("Threshold", 0.75))
                .lineStyle(StrokeStyle(lineWidth: 0.5, dash: [4]))
                .foregroundStyle(.gray.opacity(0.3))
            
            RuleMark(y: .value("Threshold", 1.5))
                .lineStyle(StrokeStyle(lineWidth: 0.5, dash: [4]))
                .foregroundStyle(.gray.opacity(0.4))
            
            RuleMark(y: .value("Threshold", 2.25))
                .lineStyle(StrokeStyle(lineWidth: 0.5, dash: [4]))
                .foregroundStyle(.gray.opacity(0.4))
                
            RuleMark(y: .value("Threshold", 3.0))
                .lineStyle(StrokeStyle(lineWidth: 0.5, dash: [4]))
                .foregroundStyle(.gray.opacity(0.3))
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
    }
}

#Preview {
    NavigationStack {
        DistanceSummaryView(store: ActivityStore())
    }
}
