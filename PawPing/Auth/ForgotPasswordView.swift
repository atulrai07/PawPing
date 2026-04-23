//
//  ForgotPasswordView.swift
//  PawPing
//
//  Created by Antigravity on 23/04/26.
//
//  First step of the forgot-password flow.
//  User enters their email to receive a recovery OTP.
//

import SwiftUI

struct ForgotPasswordView: View {

    @Bindable var store: AuthStore

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {

            Spacer()
                .frame(height: 80)

            // MARK: - Title
            Text("Email for Recovering Password")
                .font(.system(.title3, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.bottom, 28)

            // MARK: - Email Field
            VStack(alignment: .leading, spacing: 6) {
                Text("Enter Your Email Address")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                AuthTextField(
                    placeholder: "Enter Your Email Address",
                    text: $store.email,
                    icon: "envelope",
                    keyboardType: .emailAddress,
                    textContentType: .emailAddress
                )
            }
            .padding(.horizontal, 24)

            // MARK: - Submit Button
            Button {
                store.navigate(to: .otp(context: .forgotPassword))
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
            .padding(.top, 28)

            Spacer()

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
        ForgotPasswordView(store: AuthStore())
    }
}
