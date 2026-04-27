//
//  SeverityBadgeView.swift
//  PawPing
//
//  Created by Antigravity on 24/04/26.
//
//  A color-coded capsule badge that displays the severity level.
//  Green (mild), Orange (moderate), Red-orange (serious), Red (critical).
//

import SwiftUI

struct SeverityBadgeView: View {
    let severity: ConditionSeverity
    var isLarge: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: severity.icon)
                .font(.system(size: isLarge ? 16 : 12, weight: .bold))

            Text(severity.label)
                .font(.system(size: isLarge ? 16 : 12, weight: .semibold))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, isLarge ? 20 : 12)
        .padding(.vertical, isLarge ? 10 : 6)
        .background(
            Capsule()
                .fill(severity.color)
        )
    }
}

#Preview {
    VStack(spacing: 12) {
        SeverityBadgeView(severity: .mild)
        SeverityBadgeView(severity: .moderate)
        SeverityBadgeView(severity: .serious, isLarge: true)
        SeverityBadgeView(severity: .critical, isLarge: true)
    }
    .padding()
}
