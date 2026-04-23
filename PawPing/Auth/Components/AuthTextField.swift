//
//  AuthTextField.swift
//  PawPing
//
//  Created by Antigravity on 23/04/26.
//
//  Reusable capsule-style text field for the auth screens.
//  Supports regular text input and secure (password) mode with
//  a visibility toggle. Uses default iOS system styling — no
//  hardcoded sizes apart from corner radius for the capsule shape.
//

import SwiftUI

struct AuthTextField: View {

    let placeholder: String
    @Binding var text: String
    var icon: String? = nil
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil

    /// Internal toggle for password visibility — owned by this view.
    @State private var isRevealed: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            // Leading icon
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundStyle(.secondary)
                    .font(.body)
            }

            // Text input — switches between secure and plain
            if isSecure && !isRevealed {
                SecureField(placeholder, text: $text)
                    .textContentType(textContentType)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .textContentType(textContentType)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }

            // Trailing eye toggle for secure fields
            if isSecure {
                Button {
                    isRevealed.toggle()
                } label: {
                    Image(systemName: isRevealed ? "eye.fill" : "eye.slash.fill")
                        .foregroundStyle(.secondary)
                        .font(.body)
                }
            }
        } // HStack
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.systemGray6))
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        AuthTextField(
            placeholder: "Email",
            text: .constant(""),
            icon: "envelope",
            keyboardType: .emailAddress
        )
        AuthTextField(
            placeholder: "Password",
            text: .constant(""),
            icon: "lock",
            isSecure: true
        )
    }
    .padding()
}
