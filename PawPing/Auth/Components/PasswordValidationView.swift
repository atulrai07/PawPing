//
//  PasswordValidationView.swift
//  PawPing
//
//  Created by Antigravity on 23/04/26.
//
//  Shows password validation rules with pass/fail indicators.
//  Each rule displays a checkmark (green) when met, or a circle (gray) when not.
//  Used on Set Details and Set New Password screens.
//

import SwiftUI

struct PasswordValidationView: View {

    let rules: [PasswordRule]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(rules) { rule in
                HStack(spacing: 8) {
                    Image(systemName: rule.isMet
                          ? "checkmark.circle.fill"
                          : "circle")
                        .foregroundStyle(rule.isMet ? .green : .secondary)
                        .font(.subheadline)

                    Text(rule.label)
                        .font(.subheadline)
                        .foregroundStyle(rule.isMet ? .primary : .secondary)
                }
            }
        }
    }
}

#Preview {
    PasswordValidationView(rules: [
        PasswordRule(label: "Must be at least 8 Characters", isMet: true),
        PasswordRule(label: "Must contain one special character", isMet: false)
    ])
    .padding()
}
