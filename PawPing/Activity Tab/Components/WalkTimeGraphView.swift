//
//  WalkTimeGraph.swift
//  PawPing
//
//  Created by Atul on 01/02/26.
//
//  A weekly walk graph using Swift Charts.
//  Shows a filled area + line + dots for each day, with a dashed goal line.
//  The current day gets a highlighted capsule label on the X axis.
//

import SwiftUI
import Charts

struct WalkTimeGraphView: View {

    var model: TimeWalkedGraphModel
    let currentDay = "FRI"

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 34)
                .fill(Color.pawNeutral)

            VStack(alignment: .leading, spacing: 12) {

                Text("Time Walked")
                    .font(.system(size: 16, weight: .regular))

                Chart {
                    ForEach(model.data) { item in

                        // Line
                        LineMark(
                            x: .value("Day", item.day),
                            y: .value("Minutes", item.minutes)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(Color("baseColor"))
                        .lineStyle(StrokeStyle(lineWidth: 3))

                        // Area
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

                        // Points
                        PointMark(
                            x: .value("Day", item.day),
                            y: .value("Minutes", item.minutes)
                        )
                        .symbolSize(40)
                        .foregroundStyle(Color("baseColor"))
                    }

                    // Goal line
                    RuleMark(
                        y: .value("Goal", model.goalMinutes)
                    )
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4,4]))
                    .foregroundStyle(Color.gray)
                }

                // X Axis
                .chartXAxis {
                    AxisMarks(values: model.data.map { $0.day }) { value in
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
