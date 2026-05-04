//
//  DietProgressView.swift
//  PawPing
//
//  Created by Atul on 25/04/26.
//
//

import SwiftUI

struct DietProgressView: View {
    var consumed: Double
    var target: Double
    var goal: DietGoal

    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(consumed / target, 1.5)  // cap at 150% for visual
    }

    private var progressColor: Color {
        if consumed > target * 1.1 {
            return .red
        } else if consumed >= target * 0.9 {
            return .green
        } else {
            return Color("baseColor")
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    Text("Diet Plan Active")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.green)
                }

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: goal.icon)
                        .font(.system(size: 12))
                    Text(goal.rawValue)
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundStyle(Color("secondaryText"))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color("secondaryCardBackground"))
                )
            }

            // Calorie numbers
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text("\(Int(consumed))")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.primary)
                    .contentTransition(.numericText())

                Text("/ \(Int(target)) kcal")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color("secondaryText"))
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color("secondaryCardBackground"))
                        .frame(height: 10)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(progressColor)
                        .frame(width: min(geo.size.width * progress, geo.size.width), height: 10)
                        .animation(.easeInOut(duration: 0.4), value: progress)
                }
            }
            .frame(height: 10)

            // Remaining / Over label
            HStack {
                if consumed > target {
                    Text("Over by \(Int(consumed - target)) kcal")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.red)
                } else {
                    Text("\(Int(target - consumed)) kcal remaining")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color("secondaryText"))
                }

                Spacer()

                Text(goal.subtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(Color("secondaryText").opacity(0.7))
            }
        }
        .padding(16)
        .background(Color("cardBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .animation(.easeInOut, value: consumed)
    }
}

#Preview {
    VStack(spacing: 16) {
        DietProgressView(consumed: 860, target: 1250, goal: .loseWeight)
        DietProgressView(consumed: 1400, target: 1250, goal: .maintain)
    }
    .padding()
    .background(Color("baseBackground"))
}
