//
//  OTPVerificationView.swift
//  PawPing
//
//  Created by Antigravity on 2026-06-21.
//

import SwiftUI
import Combine
import Supabase

struct OTPVerificationView: View {
    @Binding var path: NavigationPath
    let email: String
    var name: String = ""
    var password: String = ""
    let isReset: Bool
    
    @Environment(AuthStore.self) var authStore
    @Environment(AppState.self) var appState
    
    @State private var code = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    // Resend countdown timer
    @State private var timeRemaining = 60
    @State private var isTimerActive = true
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @FocusState private var isKeyboardFocused: Bool
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color("baseColor").opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "envelope.badge")
                        .font(.system(size: 24))
                        .foregroundStyle(Color("baseColor"))
                }
                .padding(.top, 40)
                
                // Header
                VStack(spacing: 8) {
                    Text("Check your Email")
                        .font(.system(size: 24, weight: .bold))
                    
                    Text("We sent a 6-digit verification code to\n\(email)")
                        .font(.system(size: 16))
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                }
                
                // OTP Input Field
                ZStack {
                    // Hidden TextField that captures input
                    TextField("", text: $code)
                        .keyboardType(.numberPad)
                        .textContentType(.oneTimeCode)
                        .focused($isKeyboardFocused)
                        .opacity(0.01)
                        .frame(width: 1, height: 1)
                        .onChange(of: code) { _, newValue in
                            let filtered = newValue.filter { $0.isNumber }
                            if filtered.count > 6 {
                                code = String(filtered.prefix(6))
                            } else {
                                code = filtered
                            }
                            
                            // Automatically verify once 6 digits are typed
                            if code.count == 6 {
                                verify()
                            }
                        }
                    
                    // Styled 6-digit box layout
                    HStack(spacing: 10) {
                        ForEach(0..<6, id: \.self) { index in
                            let char = getChar(at: index)
                            let isCurrent = index == code.count
                            let isFocused = isKeyboardFocused && isCurrent
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(isFocused ? Color("baseColor") : Color(.systemGray4), lineWidth: isFocused ? 2 : 1)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(isFocused ? Color("baseColor").opacity(0.05) : Color(.systemGray6))
                                    )
                                    .frame(width: 45, height: 52)
                                
                                Text(char)
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.primary)
                            }
                            .onTapGesture {
                                isKeyboardFocused = true
                            }
                        }
                    }
                }
                .padding(.vertical, 10)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.system(size: 14))
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }
                
                // Resend section
                HStack(spacing: 4) {
                    if timeRemaining > 0 {
                        Text("Didn't receive the code? Resend in")
                            .font(.system(size: 14))
                            .foregroundStyle(.gray)
                        Text("\(timeRemaining)s")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.gray)
                    } else {
                        Text("Didn't receive the code?")
                            .font(.system(size: 14))
                            .foregroundStyle(.gray)
                        Button {
                            resendCode()
                        } label: {
                            Text("Resend")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(Color("baseColor"))
                        }
                    }
                }
                .onReceive(timer) { _ in
                    if isTimerActive && timeRemaining > 0 {
                        timeRemaining -= 1
                    }
                }
                .padding(.top, 8)
                
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
                    .disabled(isLoading || code.count < 6)
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
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.primary)
                }
            }
        }
        .background(Color(uiColor: .systemBackground))
        .onAppear {
            // Auto focus keyboard on load
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isKeyboardFocused = true
            }
        }
    }
    
    private func getChar(at index: Int) -> String {
        guard index < code.count else { return "" }
        let charIndex = code.index(code.startIndex, offsetBy: index)
        return String(code[charIndex])
    }
    
    private func resendCode() {
        timeRemaining = 60
        isTimerActive = true
        errorMessage = ""
        code = ""
        
        Task {
            do {
                try await authStore.sendOTP(email: email, purpose: isReset ? "reset" : "signup")
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func verify() {
        guard code.count == 6 else {
            errorMessage = "Please enter all 6 digits."
            return
        }
        
        isLoading = true
        errorMessage = ""
        isKeyboardFocused = false
        
        Task {
            do {
                try await authStore.verifyOTP(email: email, code: code, purpose: isReset ? "reset" : "signup")
                
                if isReset {
                    path.append(AuthRoute.resetPassword(email: email, code: code))
                } else {
                    // For signup, verification has succeeded. We now create and sign in the user.
                    _ = try await authStore.signup(name: name, email: email, password: password)
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    OTPVerificationView(path: $path, email: "you@gmail.com", isReset: false)
        .environment(AuthStore())
        .environment(AppState())
}
