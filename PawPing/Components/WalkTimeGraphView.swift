//
//  WalkTimeGraphView.swift
//  PawPing
//
//  Created by Atul on 02/02/26.
//

import SwiftUI

struct WalkTimeGraphView: View {

    var model: TimeWalkedGraphModel = .sample
    
    // Configurable dimensions
    private let graphHeight: CGFloat = 120 // Increased height for better visual
    private let pointSize: CGFloat = 10
    private let lineWidth: CGFloat = 4

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Text("Time Walked")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)

            VStack(spacing: 10) {
                // 1. Day Labels (Moved to Top)
                HStack(spacing: 0) {
                    ForEach(model.data.indices, id: \.self) { index in
                        let item = model.data[index]
                        Text(item.day)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(item.day == "FRI" ? .white : .gray)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                item.day == "FRI" ? Color("baseRed") : .clear
                            )
                            .clipShape(Capsule())
                            .frame(width: spacing) // Ensure label centers on grid line
                    }
                }
                
                // 2. The Graph Area
                ZStack(alignment: .bottomLeading) {
                    
                    // Vertical Grid Lines
                    HStack(spacing: 0) {
                        ForEach(model.data.indices, id: \.self) { _ in
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 1)
                                .frame(maxHeight: .infinity)
                                .frame(width: spacing)
                        }
                    }
                    
                    // Goal Dotted Line & Label
                    ZStack(alignment: .topTrailing) {
                        Path { path in
                            let y = yPosition(for: model.goalMinutes)
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: graphWidth, y: y))
                        }
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                        .foregroundStyle(.gray.opacity(0.8))
                        
                        // "60 min" Label
                        Text("\(model.goalMinutes) min")
                            .font(.system(size: 10))
                            .foregroundColor(.black)
                            .offset(x: 0, y: yPosition(for: model.goalMinutes) - 8)
                            .padding(.trailing, -35) // Push outside slightly or adjust as needed
                    }

                    // Smooth Area Fill
                    smoothPath(for: model.data, isClosed: true)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color("baseRed").opacity(0.4),
                                    Color("baseRed").opacity(0.05)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    // Smooth Line Stroke
                    smoothPath(for: model.data, isClosed: false)
                        .stroke(Color("baseRed"), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))

                    // Data Points
                    ForEach(model.data.indices, id: \.self) { index in
                        let item = model.data[index]
                        let x = CGFloat(index) * spacing + (spacing / 2) // Center in column
                        let y = yPosition(for: item.minutes)
                        
                        Circle()
                            .fill(.white)
                            .frame(width: pointSize, height: pointSize)
                            .overlay(
                                Circle()
                                    .stroke(Color("baseRed"), lineWidth: 2)
                            )
                            .position(x: x, y: y)
                    }
                }
                .frame(height: graphHeight)
                .frame(width: graphWidth)
            }
        }
        .padding(20)
        .background(Color.white) // Ensure background matches card
        .cornerRadius(20)
    }

    // MARK: - Helpers

    // Calculates width dynamically based on columns
    private var spacing: CGFloat {
        graphWidth / CGFloat(model.data.count)
    }

    private var graphWidth: CGFloat {
        UIScreen.main.bounds.width - 60
    }

    private func yPosition(for minutes: Int) -> CGFloat {
        let maxVal = CGFloat(model.maxMinutes)
        let ratio = CGFloat(minutes) / (maxVal == 0 ? 1 : maxVal)
        // Invert Y because 0 is at top in iOS coords
        return graphHeight - (ratio * graphHeight)
    }
    
    // MARK: - Path Generation
    
    /// Generates a smooth bezier path through the data points
    private func smoothPath(for data: [TimeWalkedData], isClosed: Bool) -> Path {
        Path { path in
            guard !data.isEmpty else { return }
            
            // Calculate points
            let points = data.indices.map { index -> CGPoint in
                let x = CGFloat(index) * spacing + (spacing / 2)
                let y = yPosition(for: data[index].minutes)
                return CGPoint(x: x, y: y)
            }
            
            // Start
            path.move(to: points[0])
            
            // Curve logic
            for i in 1..<points.count {
                let p0 = points[i - 1]
                let p1 = points[i]
                
                // Simple control point calculation for smoothness
                let midPoint = CGPoint(x: (p0.x + p1.x) / 2, y: (p0.y + p1.y) / 2)
                let control1 = CGPoint(x: (p0.x + midPoint.x) / 2, y: p0.y)
                let control2 = CGPoint(x: (midPoint.x + p1.x) / 2, y: p1.y)
                
                path.addCurve(to: p1, control1: control1, control2: control2)
            }
            
            if isClosed {
                // Close the path down to bottom corners for the gradient fill
                if let last = points.last, let first = points.first {
                    path.addLine(to: CGPoint(x: last.x, y: graphHeight))
                    path.addLine(to: CGPoint(x: first.x, y: graphHeight))
                    path.closeSubpath()
                }
            }
        }
    }
}

#Preview {
    ZStack {
        WalkTimeGraphView()
    }
}
