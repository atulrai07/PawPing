//
//  LoginView.swift
//  PawPing
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @Binding var path: NavigationPath
    @Environment(AuthStore.self) var authStore
    @Environment(AppState.self) var appState
    
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var appleSignInCoordinator: SignInWithAppleCoordinator? = nil
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 32) {
                // Header (Logo)
                HStack {
                    Spacer()
                    Image("Pawping_logo")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 62.5)
                        .foregroundStyle(Color("baseColor"))
                    Spacer()
                }
                .padding(.top, 33)
                
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
                        
                        ZStack(alignment: .leading) {
                            if email.isEmpty {
                                Text("you@gmail.com")
                                    .foregroundStyle(.gray)
                                    .opacity(0.5)
                                    .padding(.leading, 16)
                            }
                            TextField("", text: $email)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .padding(14)
                        }
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.gray)
                        
                        HStack {
                            if isPasswordVisible {
                                TextField("...............", text: $password)
                            } else {
                                SecureField("...............", text: $password)
                            }
                            
                            Button {
                                isPasswordVisible.toggle()
                            } label: {
                                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                    .foregroundStyle(.gray)
                            }
                        }
                        .padding(14)
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
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
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
                        isLoading = true
                        errorMessage = ""
                        let coordinator = SignInWithAppleCoordinator(authStore: authStore) { error in
                            self.errorMessage = error.localizedDescription
                            self.isLoading = false
                        } onSuccess: {
                            self.isLoading = false
                        }
                        self.appleSignInCoordinator = coordinator
                        
                        let provider = ASAuthorizationAppleIDProvider()
                        let request = provider.createRequest()
                        request.requestedScopes = [.fullName, .email]
                        
                        let controller = ASAuthorizationController(authorizationRequests: [request])
                        controller.delegate = coordinator
                        controller.presentationContextProvider = coordinator
                        controller.performRequests()
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
                }
                
                Spacer(minLength: 20)
                
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
                .padding(.bottom, 45)
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
                errorMessage = error.localizedDescription
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
