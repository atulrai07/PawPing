//
//  ResetPasswordView.swift
//  PawPing
//
//  Created by Atul on 2026-06-21.
//

import SwiftUI
import Supabase

struct ResetPasswordView: View {
    @Binding var path: NavigationPath
    let email: String
    let code: String
    
    @Environment(AuthStore.self) var authStore
    
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Set New Password")
                        .font(.system(size: 24, weight: .bold))
                }
                .padding(.top, 40)
                
                // Form
                VStack(spacing: 20) {
                    // Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("New password")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.gray)
                        
                        SecureField("Enter new password", text: $password)
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // Confirm Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Confirm password")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.gray)
                        
                        SecureField("Re- Enter Password", text: $confirmPassword)
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundStyle(.red)
                    }
                }
                
                // Action Buttons
                VStack(spacing: 16) {
                    Button {
                        resetPassword()
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
                    .disabled(isLoading || password.isEmpty || confirmPassword.isEmpty)
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
    }
    
    private func resetPassword() {
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                try await authStore.resetPassword(email: email, code: code, newPassword: password)
                // Pop back to root (Login)
                path.removeLast(path.count)
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    ResetPasswordView(path: $path, email: "test@example.com", code: "123456")
        .environment(AuthStore())
}
