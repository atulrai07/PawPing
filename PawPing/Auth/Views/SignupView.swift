//
//  SignupView.swift
//  PawPing
//

import SwiftUI

struct SignupView: View {
    @Binding var path: NavigationPath
    @EnvironmentObject var authStore: AuthStore
    @EnvironmentObject var appState: AppState
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // Header (Logo)
                HStack {
                    Spacer()
                    Text("PawPing")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(Color("baseColor"))
                    Spacer()
                }
                .padding(.top, 20)
                .padding(.bottom, 10)
                
                // Welcome Text
                Text("Create your account")
                    .font(.system(size: 24, weight: .bold))
                
                // Form
                VStack(spacing: 20) {
                    // Name Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Name")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.gray)
                        
                        TextField("Shailesh Kumar", text: $name)
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // Email Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.gray)
                        
                        TextField("you@gmail.com", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.gray)
                        
                        SecureField("At least 8 characters", text: $password)
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
                
                // Sign Up / Next Button
                Button {
                    signup()
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
                .disabled(isLoading || name.isEmpty || email.isEmpty || password.isEmpty)
                
                // Divider
                HStack {
                    Rectangle().frame(height: 1).foregroundStyle(Color(.systemGray4))
                    Text("or")
                        .font(.system(size: 14))
                        .foregroundStyle(.gray)
                    Rectangle().frame(height: 1).foregroundStyle(Color(.systemGray4))
                }
                
                // Social Buttons
                VStack(spacing: 16) {
                    Button {
                        // Apple Login
                    } label: {
                        HStack {
                            Image(systemName: "applelogo")
                                .font(.system(size: 20))
                                .foregroundStyle(.black)
                            Text("Continue with Apple")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.black)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Button {
                        // Google Login
                    } label: {
                        HStack {
                            Image("google_logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                            Text("Continue with Google")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.black)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                
                Spacer(minLength: 40)
                
                // Bottom link
                HStack(spacing: 4) {
                    Spacer()
                    Text("Already have an account?")
                        .font(.system(size: 14))
                        .foregroundStyle(.gray)
                    
                    Button("Sign in") {
                        dismiss()
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color("baseColor"))
                    Spacer()
                }
                .padding(.bottom, 20)
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
    
    private func signup() {
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                try await authStore.sendOTP(email: email)
                path.append(AuthRoute.otp(email: email, isReset: false))
            } catch {
                errorMessage = "Failed to send verification code."
            }
            isLoading = false
        }
    }
}

struct SignupViewPreviewWrapper: View {
    @State private var path = NavigationPath()
    var body: some View {
        SignupView(path: $path)
            .environmentObject(AuthStore())
            .environmentObject(AppState())
    }
}

#Preview {
    SignupViewPreviewWrapper()
}
