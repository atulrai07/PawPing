//
//  CalorieBadgeView.swift
//  PawPing
//
//  Created by Atul on 25/04/26.
//
//  Compact badge displaying calorie count with a flame icon.
//  Used on meal cards and in the logging sheet for instant feedback.
//  Animates smoothly when calorie value changes.
//

import SwiftUI

struct CalorieBadgeView: View {
    var calories: Double
    var style: BadgeStyle = .compact

    enum BadgeStyle {
        case compact    // small inline badge (meal cards)
        case prominent  // larger badge (logging sheet feedback)
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .font(.system(size: style == .compact ? 10 : 14))
                .foregroundStyle(.orange)

            Text("\(Int(calories)) kcal")
                .font(.system(size: style == .compact ? 12 : 16, weight: .semibold))
                .foregroundStyle(style == .compact ? Color("secondaryText") : Color("baseColor"))
                .contentTransition(.numericText())
        }
        .padding(.horizontal, style == .compact ? 8 : 14)
        .padding(.vertical, style == .compact ? 4 : 8)
        .background(
            RoundedRectangle(cornerRadius: style == .compact ? 8 : 12)
                .fill(Color.orange.opacity(0.1))
        )
        .animation(.easeInOut(duration: 0.2), value: calories)
    }
}

#Preview {
    VStack(spacing: 16) {
        CalorieBadgeView(calories: 350, style: .compact)
        CalorieBadgeView(calories: 520, style: .prominent)
    }
}
