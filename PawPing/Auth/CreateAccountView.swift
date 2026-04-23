//
//  CreateAccountView.swift
//  PawPing
//
//  Created by Antigravity on 23/04/26.
//
//  New account creation screen — step 1: enter email.
//  Shows logo, email field, Next button, and social sign-in.
//

import SwiftUI

struct CreateAccountView: View {

    @Bindable var store: AuthStore
    var onAuthenticated: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {

                // MARK: - Logo
                Image("pawping (1)")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 260)
                    .padding(.top, 60)
                    .padding(.bottom, 40)

                // MARK: - Email Field
                VStack(alignment: .leading, spacing: 10) {
                    Text("Enter your email")
                        .font(.system(.body, weight: .medium))

                    AuthTextField(
                        placeholder: "yourname@email.com",
                        text: $store.email,
                        icon: "envelope",
                        keyboardType: .emailAddress,
                        textContentType: .emailAddress
                    )
                }
                .padding(.horizontal, 24)

                // MARK: - Next Button
                Button {
                    store.navigate(to: .otp(context: .createAccount))
                } label: {
                    Text("Next")
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
                .padding(.top, 24)

                // MARK: - Divider "or"
                HStack {
                    Rectangle()
                        .fill(Color(.systemGray4))
                        .frame(height: 1)
                    Text("or")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Rectangle()
                        .fill(Color(.systemGray4))
                        .frame(height: 1)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 24)

                // MARK: - Social Sign-In
                VStack(spacing: 12) {
                    SocialSignInButton(
                        title: "Continue with Apple",
                        icon: "apple.logo",
                        action: {
                            onAuthenticated()
                        }
                    )

                    SocialSignInButton(
                        title: "Continue with Google",
                        icon: "g.circle.fill",
                        action: {
                            onAuthenticated()
                        }
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)

            } // VStack
        } // ScrollView
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
        CreateAccountView(store: AuthStore(), onAuthenticated: {})
    }
}
