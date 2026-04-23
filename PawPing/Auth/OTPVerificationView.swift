//
//  OTPVerificationView.swift
//  PawPing
//
//  Created by Antigravity on 23/04/26.
//
//  4-digit OTP input screen. Reused for both create-account
//  and forgot-password flows — the `context` determines
//  which screen comes next after Submit.
//

import SwiftUI

struct OTPVerificationView: View {

    @Bindable var store: AuthStore
    let context: OTPContext

    @Environment(\.dismiss) private var dismiss

    /// Each OTP box gets its own focus case.
    @FocusState private var focusedField: Int?

    var body: some View {
        VStack(spacing: 0) {

            Spacer()
                .frame(height: 60)

            // MARK: - Icon
            Image(systemName: "envelope.badge.fill")
                .font(.system(size: 40))
                .foregroundStyle(Color("baseColor"))
                .padding(.bottom, 20)

            // MARK: - Title & Subtitle
            Text("Check your Email")
                .font(.system(.title2, weight: .bold))
                .padding(.bottom, 6)

            Text("We sent a code to\n\(store.maskedEmail)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 32)

            // MARK: - OTP Boxes
            HStack(spacing: 14) {
                ForEach(0..<4, id: \.self) { index in
                    OTPBox(
                        text: $store.otpDigits[index],
                        isFocused: focusedField == index
                    )
                    .focused($focusedField, equals: index)
                    .onChange(of: store.otpDigits[index]) { _, newValue in
                        // Auto-advance to next box
                        if newValue.count == 1 && index < 3 {
                            focusedField = index + 1
                        }
                        // Handle backspace — go back to previous box
                        if newValue.isEmpty && index > 0 {
                            focusedField = index - 1
                        }
                        // Clamp to 1 character
                        if newValue.count > 1 {
                            store.otpDigits[index] = String(newValue.suffix(1))
                        }
                    }
                }
            }
            .padding(.bottom, 36)

            // MARK: - Submit Button
            Button {
                switch context {
                case .createAccount:
                    store.navigate(to: .setDetails)
                case .forgotPassword:
                    store.navigate(to: .forgotSetPassword)
                }
            } label: {
                Text("Submit")
                    .font(.system(.body, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color("baseColor"))
                    )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)

            Spacer()

        } // VStack
        .background(Color("baseBackground").ignoresSafeArea())
        .onAppear {
            focusedField = 0
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.medium))
                        .foregroundStyle(.primary)
                }
            }
        }
    }
}

// MARK: - Single OTP Box

/// A single digit box in the OTP row.
/// Styled with rounded border that highlights when focused.
private struct OTPBox: View {

    @Binding var text: String
    var isFocused: Bool

    var body: some View {
        TextField("", text: $text)
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            .font(.system(.title2, weight: .bold))
            .frame(width: 56, height: 56)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(
                        isFocused ? Color("baseColor") : Color(.systemGray4),
                        lineWidth: isFocused ? 2 : 1
                    )
            )
    }
}

#Preview {
    NavigationStack {
        OTPVerificationView(store: AuthStore(), context: .createAccount)
    }
}
