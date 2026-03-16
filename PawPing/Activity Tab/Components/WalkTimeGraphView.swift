//
//  WalkTimeGraph.swift
//  PawPing
//
//  Created by Atul on 01/02/26.
//
import SwiftUI
import Charts

struct WalkTimeGraphView: View {

    var model: TimeWalkedGraphModel
    let currentDay = "FRI"   // highlight this

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 34)
                .fill(.gray.opacity(0.1))

            VStack(alignment: .leading, spacing: 12) {

                Text("Time Walked")
                    .font(.system(size: 16, weight: .regular))

                Chart {

                    ForEach(model.data) { item in

                        LineMark(
                            x: .value("Day", item.day),
                            y: .value("Minutes", item.minutes)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(Color("baseRed"))
                        .lineStyle(StrokeStyle(lineWidth: 3))

                        AreaMark(
                            x: .value("Day", item.day),
                            y: .value("Minutes", item.minutes)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color("baseRed").opacity(0.4),
                                    Color("baseRed").opacity(0.05)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                        PointMark(
                            x: .value("Day", item.day),
                            y: .value("Minutes", item.minutes)
                        )
                        .symbolSize(40)
                        .foregroundStyle(Color("baseRed"))
                    }

                    RuleMark(
                        y: .value("Goal", model.goalMinutes)
                    )
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4,4]))
                    .foregroundStyle(Color.gray)
                }

                // Only modification: custom X labels
                .chartXAxis {
                    AxisMarks(values: model.data.map{$0.day}) { value in
                        AxisGridLine()   // keeps vertical mesh
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
                                        ? Color("baseRed")
                                        : Color.clear
                                    )
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }

                // keep minute labels and horizontal grid
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
