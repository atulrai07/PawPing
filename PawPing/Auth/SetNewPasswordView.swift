//
//  SetNewPasswordView.swift
//  PawPing
//
//  Created by Antigravity on 23/04/26.
//
//  Final step of the forgot-password flow.
//  User enters a new password + confirmation with validation.
//

import SwiftUI

struct SetNewPasswordView: View {

    @Bindable var store: AuthStore
    var onAuthenticated: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {

            Spacer()
                .frame(height: 40)

            // MARK: - Icon
            Image(systemName: "lock.rotation")
                .font(.system(size: 36))
                .foregroundStyle(Color("baseColor"))
                .padding(.bottom, 16)

            // MARK: - Title & Subtitle
            Text("Set New Password")
                .font(.system(.title2, weight: .bold))
                .padding(.bottom, 4)

            Text("Your new password must be different\nfrom your previous password.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 28)

            // MARK: - Password Fields
            VStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("New Password")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    AuthTextField(
                        placeholder: "Enter New Password",
                        text: $store.newPassword,
                        icon: "lock",
                        isSecure: true,
                        textContentType: .newPassword
                    )
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Confirm Password")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    AuthTextField(
                        placeholder: "Re-Enter Password",
                        text: $store.confirmPassword,
                        icon: "lock",
                        isSecure: true,
                        textContentType: .newPassword
                    )
                }
            }
            .padding(.horizontal, 24)

            // MARK: - Password Validation
            PasswordValidationView(rules: store.newPasswordRules)
                .padding(.horizontal, 28)
                .padding(.top, 14)

            Spacer()

            // MARK: - Submit Button
            Button {
                // Stub: password reset complete → back to login or home
                onAuthenticated()
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
            .padding(.bottom, 40)

        } // VStack
        .background(Color("baseBackground").ignoresSafeArea())
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

#Preview {
    NavigationStack {
        SetNewPasswordView(store: AuthStore(), onAuthenticated: {})
    }
}
