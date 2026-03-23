//
//  WalkTimeGraph.swift
//  PawPing
//
//  Created by Atul on 01/02/26.
//
//  A weekly walk graph using Swift Charts.
//  Shows a filled area + line + dots for each day, with a dashed goal line.
//  The current day gets a highlighted blue capsule label on the X axis.
//

import SwiftUI
import Charts   // Apple's native Charts framework (iOS 16+)

struct WalkTimeGraphView: View {

    var model: TimeWalkedGraphModel
    let currentDay = "FRI"   // highlight this day on the X axis

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 34)
                .fill(Color.pawNeutral)

            VStack(alignment: .leading, spacing: 12) {

                Text("Time Walked")
                    .font(.system(size: 16, weight: .regular))

                Chart {
                    ForEach(model.data) { item in

                        // Smooth line connecting the daily values
                        LineMark(
                            x: .value("Day", item.day),
                            y: .value("Minutes", item.minutes)
                        )
                        .interpolationMethod(.catmullRom)   // smooth curves instead of straight lines
                        .foregroundStyle(Color.pawPrimary)
                        .lineStyle(StrokeStyle(lineWidth: 3))

                        // Gradient fill under the line
                        AreaMark(
                            x: .value("Day", item.day),
                            y: .value("Minutes", item.minutes)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color.pawPrimary.opacity(0.4),
                                    Color.pawPrimary.opacity(0.05)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                        // Dot on each data point
                        PointMark(
                            x: .value("Day", item.day),
                            y: .value("Minutes", item.minutes)
                        )
                        .symbolSize(40)
                        .foregroundStyle(Color.pawPrimary)
                    }

                    // Dashed horizontal line showing the daily goal
                    RuleMark(
                        y: .value("Goal", model.goalMinutes)
                    )
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4,4]))
                    .foregroundStyle(Color.gray)
                } // Chart

                // Custom X-axis labels — highlights today with a blue pill
                .chartXAxis {
                    AxisMarks(values: model.data.map{$0.day}) { value in
                        AxisGridLine()
                        AxisTick()

                        AxisValueLabel {
                            if let day = value.as(String.self) {
                                Text(day)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(day == currentDay ? .white : .gray)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        day == currentDay
                                        ? Color.pawPrimary
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
            } // VStack — chart + title
            .padding()
        } // ZStack — card
        .frame(height: 153)
        .padding(.horizontal)
    }
} // WalkTimeGraphView

#Preview {
    WalkTimeGraphView(model: ActivityStore().timeWalkedGraph)
}
