//
//  SocialSignInButton.swift
//  PawPing
//
//  Created by Antigravity on 23/04/26.
//
//  Capsule-outlined button for Apple and Google sign-in.
//  Uses SF Symbols and system font — consistent with the native iOS look.
//

import SwiftUI

struct SocialSignInButton: View {

    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.body)

                Text(title)
                    .font(.system(.body, weight: .medium))
            }
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 12) {
        SocialSignInButton(title: "Continue with Apple", icon: "apple.logo", action: {})
        SocialSignInButton(title: "Continue with Google", icon: "g.circle.fill", action: {})
    }
    .padding()
}
