//
//  AuthFlowView.swift
//  PawPing
//

import SwiftUI

enum AuthRoute: Hashable {
    case login
    case signup
    case forgotPassword
    case otp(email: String, isReset: Bool)
    case resetPassword(email: String)
}

struct AuthFlowView: View {
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            LoginView(path: $navigationPath)
                .navigationDestination(for: AuthRoute.self) { route in
                    switch route {
                    case .login:
                        LoginView(path: $navigationPath)
                    case .signup:
                        SignupView(path: $navigationPath)
                    case .forgotPassword:
                        ForgotPasswordView(path: $navigationPath)
                    case .otp(let email, let isReset):
                        OTPVerificationView(path: $navigationPath, email: email, isReset: isReset)
                    case .resetPassword(let email):
                        ResetPasswordView(path: $navigationPath, email: email)
                    }
                }
        }
    }
}

#Preview {
    AuthFlowView()
        .environmentObject(AuthStore())
        .environmentObject(AppState())
}
