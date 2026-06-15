//
//  ForgotPasswordView.swift
//  PawPing
//

import SwiftUI
import Supabase

struct ForgotPasswordView: View {
    @Binding var path: NavigationPath
    @Environment(AuthStore.self) var authStore
    
    @State private var email = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Forgot Password")
                        .font(.system(size: 24, weight: .bold))
                }
                .padding(.top, 40)
                
                // Form
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.gray)
                        
                        TextField("you@gmail.com", text: $email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
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
                        sendResetLink()
                    } label: {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color("baseColor"))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            Text("Next")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color("baseColor"))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .disabled(isLoading || email.isEmpty)
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
    
    private func sendResetLink() {
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                try await SupabaseConfig.client.auth.resetPasswordForEmail(email)
                path.append(AuthRoute.otp(email: email, isReset: true))
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    ForgotPasswordView(path: $path)
        .environment(AuthStore())
}
