//
//  AuthFlowView.swift
//  PawPing
//
//  Created by Antigravity on 23/04/26.
//
//  The root coordinator for the entire auth flow.
//  Hosts a NavigationStack with the LoginView as the root,
//  and uses navigationDestination(for: AuthRoute.self) for
//  type-safe routing to all auth sub-screens.
//
//  When authentication completes (login, social sign-in, or
//  account creation), the onAuthenticated callback fires to
//  tell ContentView to transition to the Home screen.
//

import SwiftUI

struct AuthFlowView: View {

    /// The auth store lives here — owned by the flow coordinator.
    @State private var store = AuthStore()

    /// Called when auth is complete — ContentView advances to Home.
    var onAuthenticated: () -> Void

    var body: some View {
        NavigationStack(path: $store.path) {

            // Root screen: Login
            LoginView(store: store, onAuthenticated: onAuthenticated)

                // MARK: - Route Handling
                .navigationDestination(for: AuthRoute.self) { route in
                    switch route {

                    case .createAccount:
                        CreateAccountView(
                            store: store,
                            onAuthenticated: onAuthenticated
                        )

                    case .otp(let context):
                        OTPVerificationView(
                            store: store,
                            context: context
                        )

                    case .setDetails:
                        SetDetailsView(
                            store: store,
                            onAuthenticated: onAuthenticated
                        )

                    case .setProfile:
                        SetProfileView(
                            store: store,
                            onAuthenticated: onAuthenticated
                        )

                    case .forgotPassword:
                        ForgotPasswordView(store: store)

                    case .forgotOTP:
                        OTPVerificationView(
                            store: store,
                            context: .forgotPassword
                        )

                    case .forgotSetPassword:
                        SetNewPasswordView(
                            store: store,
                            onAuthenticated: onAuthenticated
                        )
                    }
                } // navigationDestination
        } // NavigationStack
    }
}

#Preview {
    AuthFlowView(onAuthenticated: {})
}
