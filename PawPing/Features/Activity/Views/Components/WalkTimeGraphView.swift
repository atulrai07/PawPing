//
//  WalkTimeGraphView.swift
//  PawPing
//

import SwiftUI
import Charts

/// A component that renders a line/area chart showing the pet's walking time over the week.
struct WalkTimeGraphView: View {
    // MARK: - Properties
    var model: TimeWalkedGraphModel
    
    /// Shared formatter to avoid expensive re-initializations
    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }()
    
    /// Helper to identify the current weekday for highlighting the X-axis label
    private var currentDay: String {
        Self.dayFormatter.string(from: Date()).uppercased()
    }

    var body: some View {
        ZStack {
            // MARK: - Card Background
            RoundedRectangle(cornerRadius: 28)
                .fill(Color("cardBackground"))

            VStack(alignment: .leading, spacing: 12) {
                // MARK: - Header
                Text("Time Walked")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)

                // MARK: - Chart Content
                Chart {
                    ForEach(model.data) { item in
                        // Main Line
                        LineMark(
                            x: .value("Day", item.day),
                            y: .value("Minutes", item.minutes)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(Color("baseColor"))
                        .lineStyle(StrokeStyle(lineWidth: 3))

                        // Gradient Area fill below the line
                        AreaMark(
                            x: .value("Day", item.day),
                            y: .value("Minutes", item.minutes)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color("baseColor").opacity(0.4),
                                    Color("baseColor").opacity(0.05)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                        // Data Points
                        PointMark(
                            x: .value("Day", item.day),
                            y: .value("Minutes", item.minutes)
                        )
                        .symbolSize(40)
                        .foregroundStyle(Color("baseColor"))
                    }

                    // Horizontal Daily Goal Line
                    RuleMark(
                        y: .value("Goal", model.goalMinutes)
                    )
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4,4]))
                    .foregroundStyle(Color("secondaryText"))
                }
                .chartXAxis {
                    AxisMarks(values: model.data.map{$0.day}) { value in
                        AxisGridLine()
                        AxisTick()

                        AxisValueLabel {
                            if let day = value.as(String.self) {
                                // Highlight the current day label
                                Text(day)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(day == currentDay ? .white : Color("secondaryText"))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        day == currentDay
                                        ? Color("baseColor")
                                        : Color.clear
                                    )
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .trailing)
                }
                .frame(height: 100)
            }
            .padding()
        }
        .frame(height: 153)
        .padding(.horizontal)
    }
}

#Preview {
    WalkTimeGraphView(model: ActivityStore().timeWalkedGraph)
}
