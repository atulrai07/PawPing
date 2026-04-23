//
//  SetDetailsView.swift
//  PawPing
//
//  Created by Antigravity on 23/04/26.
//
//  After OTP verification for new accounts, users set their
//  email and password. Shows validation rules in real-time.
//

import SwiftUI

struct SetDetailsView: View {

    @Bindable var store: AuthStore
    var onAuthenticated: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {

            Spacer()
                .frame(height: 40)

            // MARK: - Icon
            Image(systemName: "person.badge.key.fill")
                .font(.system(size: 36))
                .foregroundStyle(Color("baseColor"))
                .padding(.bottom, 16)

            // MARK: - Title & Subtitle
            Text("Set Details")
                .font(.system(.title2, weight: .bold))
                .padding(.bottom, 4)

            Text("Your password must be different\nfrom your previous password.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 28)

            // MARK: - Fields
            VStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Enter your email")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    AuthTextField(
                        placeholder: "yourname@email.com",
                        text: $store.email,
                        icon: "envelope",
                        keyboardType: .emailAddress,
                        textContentType: .emailAddress
                    )
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Password")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    AuthTextField(
                        placeholder: "••••••••••••••",
                        text: $store.password,
                        icon: "lock",
                        isSecure: true,
                        textContentType: .newPassword
                    )
                }
            }
            .padding(.horizontal, 24)

            // MARK: - Password Validation
            PasswordValidationView(rules: store.passwordRules)
                .padding(.horizontal, 28)
                .padding(.top, 14)

            Spacer()

            // MARK: - Submit Button
            Button {
                // Account details saved → proceed to pet profile setup
                store.navigate(to: .setProfile)
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
        SetDetailsView(store: AuthStore(), onAuthenticated: {})
    }
}
