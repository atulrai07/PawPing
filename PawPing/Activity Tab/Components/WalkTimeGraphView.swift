//
//  WalkTimeGraphView.swift
//  PawPing
//
//  Created by Atul on 02/02/26.
//

import SwiftUI

struct WalkTimeGraphView: View {

    var model: TimeWalkedGraphModel
    
    // MARK: - Dimensions & Config
    // 1. Fixed dimensions to match the outer frame constraint
    private let cardWidth: CGFloat = 370
    private let cardHeight: CGFloat = 153
    private let internalPadding: CGFloat = 20
    
    // 2. Reduced graph height to allow room for Title and Labels within the 153pt limit
    private let graphHeight: CGFloat = 80
    private let pointSize: CGFloat = 8
    private let lineWidth: CGFloat = 3

    var body: some View {
        ZStack {
            // Background Card
            RoundedRectangle(cornerRadius: 34)
                .fill(.gray.opacity(0.1))
                .frame(width: cardWidth, height: cardHeight)
            
            // Content
            VStack(alignment: .leading, spacing: 12) {
                
                // Title
                Text("Time Walked")
                    .font(.system(size: 22, weight: .regular)) // Reduced font slightly to fit
                    .foregroundColor(.black)
                    .padding(.leading, 4) // Align with graph start
                
                VStack(spacing: 8) {
                    
                    // 1. Day Labels
                    HStack(spacing: 0) {
                        ForEach(model.data.indices, id: \.self) { index in
                            let item = model.data[index]
                            Text(item.day)
                                .font(.system(size: 10, weight: .medium)) // Smaller font
                                .foregroundStyle(item.day == "FRI" ? .white : .gray)
                                .frame(width: spacing, height: 20)
                                .background(
                                    item.day == "FRI" ? Color("baseRed") : .clear
                                )
                                .clipShape(Capsule())
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
                            
                            Text("\(model.goalMinutes) min")
                                .font(.system(size: 9))
                                .foregroundColor(.gray)
                                .offset(x: 0, y: yPosition(for: model.goalMinutes) - 12)
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
                            let x = CGFloat(index) * spacing + (spacing / 2)
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
            .padding(internalPadding)
            .frame(width: cardWidth, height: cardHeight) // Ensure content respects the frame
        }
    }

    // MARK: - Helpers

    // Calculates width dynamically based on cardWidth minus padding
    private var graphWidth: CGFloat {
        cardWidth - (internalPadding * 2)
    }
    
    private var spacing: CGFloat {
        graphWidth / CGFloat(model.data.count)
    }

    private func yPosition(for minutes: Int) -> CGFloat {
        let maxVal = CGFloat(model.maxMinutes)
        // Prevent division by zero
        let ratio = CGFloat(minutes) / (maxVal == 0 ? 1 : maxVal)
        return graphHeight - (ratio * graphHeight)
    }
    
    // MARK: - Path Generation
    private func smoothPath(for data: [TimeWalkedData], isClosed: Bool) -> Path {
        Path { path in
            guard !data.isEmpty else { return }
            
            let points = data.indices.map { index -> CGPoint in
                let x = CGFloat(index) * spacing + (spacing / 2)
                let y = yPosition(for: data[index].minutes)
                return CGPoint(x: x, y: y)
            }
            
            path.move(to: points[0])
            
            for i in 1..<points.count {
                let p0 = points[i - 1]
                let p1 = points[i]
                
                let midPoint = CGPoint(x: (p0.x + p1.x) / 2, y: (p0.y + p1.y) / 2)
                let control1 = CGPoint(x: (p0.x + midPoint.x) / 2, y: p0.y)
                let control2 = CGPoint(x: (midPoint.x + p1.x) / 2, y: p1.y)
                
                path.addCurve(to: p1, control1: control1, control2: control2)
            }
            
            if isClosed {
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
        Color.white
        WalkTimeGraphView(model: ActivityStore().timeWalkedGraph)
    }
}
