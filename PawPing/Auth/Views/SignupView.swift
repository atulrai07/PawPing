//
//  SignupView.swift
//  PawPing
//

import SwiftUI
import AuthenticationServices

struct SignupView: View {
    @Binding var path: NavigationPath
    @Environment(AuthStore.self) var authStore
    @Environment(AppState.self) var appState
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var appleSignInCoordinator: SignInWithAppleCoordinator? = nil
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // Header (Logo)
                HStack {
                    Spacer()
                    Image("pawPing_text_Image")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 60)
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
                        
                        SecureField("At least 8 characters", text: $password)
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundStyle(.red)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                
                // Sign Up Button
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
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.primary)
                }
            }
        }
        .background(Color(uiColor: .systemBackground))
    }
    
    private func signup() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let isValid = trimmedName.allSatisfy { $0.isLetter || $0.isWhitespace }
        guard isValid else {
            errorMessage = "Name must contain letters and spaces only."
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                // Send custom OTP code first
                try await authStore.sendOTP(email: email, purpose: "signup")
                // Navigate to OTP view, passing name and password for after verification login
                path.append(AuthRoute.otp(email: email, name: name, password: password, isReset: false))
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    SignupView(path: $path)
        .environment(AuthStore())
        .environment(AppState())
}
