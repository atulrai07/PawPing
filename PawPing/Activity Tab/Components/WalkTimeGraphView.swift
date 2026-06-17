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
    
    var currentDay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: Date()).uppercased()
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)

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
                        .foregroundStyle(Color("baseColor"))
                        .lineStyle(StrokeStyle(lineWidth: 3))

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

                        PointMark(
                            x: .value("Day", item.day),
                            y: .value("Minutes", item.minutes)
                        )
                        .symbolSize(40)
                        .foregroundStyle(Color("baseColor"))
                    }

                    RuleMark(
                        y: .value("Goal", model.goalMinutes)
                    )
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4,4]))
                    .foregroundStyle(Color("secondaryText"))
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
