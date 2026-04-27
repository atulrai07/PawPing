//
//  OTPVerificationView.swift
//  PawPing
//

import SwiftUI

struct OTPVerificationView: View {
    @Binding var path: NavigationPath
    let email: String
    let isReset: Bool
    
    @EnvironmentObject var authStore: AuthStore
    @EnvironmentObject var appState: AppState
    
    @State private var code = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color("baseColor").opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "envelope")
                        .font(.system(size: 24))
                        .foregroundStyle(Color("baseColor"))
                }
                .padding(.top, 40)
                
                // Header
                VStack(spacing: 8) {
                    Text("Check your Email")
                        .font(.system(size: 24, weight: .bold))
                    
                    Text("We sent a code to\n\(email)")
                        .font(.system(size: 16))
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                }
                
                // OTP Fields
                HStack(spacing: 12) {
                    ForEach(0..<4, id: \.self) { index in
                        otpBox(for: index)
                    }
                }
                .padding(.vertical, 20)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.system(size: 14))
                        .foregroundStyle(.red)
                }
                
                // Action Buttons
                VStack(spacing: 16) {
                    Button {
                        verify()
                    } label: {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color("baseColor"))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            Text("Submit")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color("baseColor"))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .disabled(isLoading) // Code validation omitted for mock UI interactions
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.black)
                        .frame(width: 40, height: 40)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
            }
        }
        .background(Color(uiColor: .systemBackground))
    }
    
    // Quick mock for OTP boxes (in a real app, this would use focused TextFields)
    private func otpBox(for index: Int) -> some View {
        let isFirst = index == 0
        return ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(isFirst ? Color("baseColor") : Color("baseColor").opacity(0.15))
                .frame(width: 50, height: 50)
            
            if isFirst {
                Text("1")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
    }
    
    private func verify() {
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                try await authStore.verifyOTP(code: "1234")
                if isReset {
                    path.append(AuthRoute.resetPassword(email: email))
                } else {
                    authStore.appState = appState
                    try await authStore.signup(name: "User", email: email, password: "password")
                }
            } catch {
                errorMessage = "Invalid or expired code."
            }
            isLoading = false
        }
    }
}

struct OTPVerificationViewPreviewWrapper: View {
    @State private var path = NavigationPath()
    var body: some View {
        OTPVerificationView(path: $path, email: "you@gmail.com", isReset: false)
            .environmentObject(AuthStore())
            .environmentObject(AppState())
    }
}

#Preview {
    OTPVerificationViewPreviewWrapper()
}
