//
//  OTPVerificationView.swift
//  PawPing
//

import SwiftUI
import Supabase

struct OTPVerificationView: View {
    @Binding var path: NavigationPath
    let email: String
    let isReset: Bool
    
    @Environment(AuthStore.self) var authStore
    @Environment(AppState.self) var appState
    
    @FocusState private var isFocused: Bool
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
                ZStack {
                    TextField("", text: $code)
                        .keyboardType(.numberPad)
                        .textContentType(.oneTimeCode)
                        .focused($isFocused)
                        .opacity(0.01)
                        .frame(width: 1, height: 1)
                        .onChange(of: code) { _, newValue in
                            let filtered = newValue.filter { $0.isNumber }
                            if filtered.count > 6 {
                                code = String(filtered.prefix(6))
                            } else {
                                code = filtered
                            }
                        }
                    
                    HStack(spacing: 12) {
                        ForEach(0..<6, id: \.self) { index in
                            otpBox(for: index)
                        }
                    }
                }
                .onTapGesture {
                    isFocused = true
                }
                .onAppear {
                    isFocused = true
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
    
    private func otpBox(for index: Int) -> some View {
        let charStr: String
        if index < code.count {
            let start = code.index(code.startIndex, offsetBy: index)
            charStr = String(code[start])
        } else {
            charStr = ""
        }
        
        let isActive = isFocused && index == code.count
        
        return ZStack {
            RoundedRectangle(cornerRadius: 12)
                .stroke(isActive ? Color("baseColor") : Color.clear, lineWidth: 2)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isActive ? Color("baseColor").opacity(0.05) : Color("baseColor").opacity(0.1))
                )
                .frame(width: 45, height: 50)
            
            Text(charStr)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color.primary)
        }
    }
    
    private func verify() {
        guard code.count == 6 else {
            errorMessage = "Please enter a 6-digit code."
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                if isReset {
                    _ = try await SupabaseConfig.client.auth.verifyOTP(
                        email: email,
                        token: code,
                        type: .recovery
                    )
                    path.append(AuthRoute.resetPassword(email: email))
                } else {
                    _ = try await SupabaseConfig.client.auth.verifyOTP(
                        email: email,
                        token: code,
                        type: .signup
                    )
                    path.removeLast(path.count)
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
