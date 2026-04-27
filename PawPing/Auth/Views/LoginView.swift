//
//  LoginView.swift
//  PawPing
//

import SwiftUI

struct LoginView: View {
    @Binding var path: NavigationPath
    @Environment(AuthStore.self) var authStore
    @Environment(AppState.self) var appState
    
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    
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
                .padding(.top, 40)
                .padding(.bottom, 20)
                
                // Welcome Text
                Text("Welcome back")
                    .font(.system(size: 24, weight: .bold))
                
                // Form
                VStack(spacing: 20) {
                    // Email Field
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
                    
                    // Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.gray)
                        
                        SecureField("...............", text: $password)
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // Forgot Password
                    HStack {
                        Spacer()
                        Button("Forgot Password ?") {
                            path.append(AuthRoute.forgotPassword)
                        }
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Color("baseColor"))
                    }
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundStyle(.red)
                    }
                }
                
                // Sign In Button
                Button {
                    login()
                } label: {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color("baseColor"))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        Text("Sign in")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color("baseColor"))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .disabled(isLoading || email.isEmpty || password.isEmpty)
                
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
                    Text("New to PawPing?")
                        .font(.system(size: 14))
                        .foregroundStyle(.gray)
                    
                    Button("Create an account") {
                        path.append(AuthRoute.signup)
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
        .background(Color(uiColor: .systemBackground))
    }
    
    private func login() {
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                try await authStore.login(email: email, password: password)
            } catch {
                errorMessage = "Failed to login. Please try again."
            }
            isLoading = false
        }
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    LoginView(path: $path)
        .environment(AuthStore())
        .environment(AppState())
}
