//
//  LoginView.swift
//  PawPing
//
//  Created by Antigravity on 23/04/26.
//
//  The first screen users see after onboarding.
//  Shows the PawPing logo, email/password fields,
//  login button, and social sign-in options.
//

import SwiftUI

struct LoginView: View {

    @Bindable var store: AuthStore
    var onAuthenticated: () -> Void

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

                // MARK: - Input Fields
                VStack(spacing: 14) {
                    AuthTextField(
                        placeholder: "Email",
                        text: $store.email,
                        icon: "envelope",
                        keyboardType: .emailAddress,
                        textContentType: .emailAddress
                    )

                    AuthTextField(
                        placeholder: "Password",
                        text: $store.password,
                        icon: "lock",
                        isSecure: true,
                        textContentType: .password
                    )
                }
                .padding(.horizontal, 24)

                // MARK: - Forgot Password
                HStack {
                    Spacer()
                    Button {
                        store.navigate(to: .forgotPassword)
                    } label: {
                        Text("Forgot Password ?")
                            .font(.subheadline)
                            .foregroundStyle(.pawPrimary)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 10)

                // MARK: - Login Button
                Button {
                    // Stub: navigate to home on login
                    onAuthenticated()
                } label: {
                    Text("Login")
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
                .padding(.vertical, 20)

                // MARK: - Create Account
                Button {
                    store.navigate(to: .createAccount)
                } label: {
                    Text("Create Account")
                        .font(.system(.body, weight: .medium))
                        .foregroundStyle(.pawPrimary)
                }
                .padding(.bottom, 20)

                // MARK: - Social Sign-In
                VStack(spacing: 12) {
                    SocialSignInButton(
                        title: "Continue with Apple",
                        icon: "apple.logo",
                        action: {
                            // Stub: Apple sign-in → home
                            onAuthenticated()
                        }
                    )

                    SocialSignInButton(
                        title: "Continue with Google",
                        icon: "g.circle.fill",
                        action: {
                            // Stub: Google sign-in → home
                            onAuthenticated()
                        }
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)

            } // VStack
        } // ScrollView
        .background(Color("baseBackground").ignoresSafeArea())
    }
}

#Preview {
    LoginView(store: AuthStore(), onAuthenticated: {})
}
