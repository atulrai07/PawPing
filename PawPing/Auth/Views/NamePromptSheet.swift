//
//  NamePromptSheet.swift
//  PawPing
//

import SwiftUI

struct NamePromptSheet: View {
    @Environment(AuthStore.self) var authStore
    @Environment(PetStore.self) var petStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                // Icon Header
                ZStack {
                    Circle()
                        .fill(Color("baseColor").opacity(0.1))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.system(size: 36))
                        .foregroundStyle(Color("baseColor"))
                }
                
                // Title and Subtitle
                VStack(spacing: 10) {
                    Text("What's your name?")
                        .font(.system(size: 26, weight: .bold))
                        .multilineTextAlignment(.center)
                    
                    Text("Please enter your name to complete your profile setup.")
                        .font(.system(size: 15))
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                
                // Text Field Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Name")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.gray)
                        .padding(.leading, 4)
                    
                    TextField("Enter your name", text: $name)
                        .font(.system(size: 16))
                        .padding(.vertical, 16)
                        .padding(.horizontal, 16)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                        )
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.system(size: 14))
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: saveName) {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color("baseColor"))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        } else {
                            Text("Save and Continue")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color("baseColor"))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                    .disabled(isLoading || name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    
                    Button("Log Out") {
                        Task {
                            await authStore.logout()
                            dismiss()
                        }
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.red)
                    .padding(.vertical, 8)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .background(Color(uiColor: .systemBackground))
            .interactiveDismissDisabled(true)
        }
    }
    
    private func saveName() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        let isValid = trimmedName.allSatisfy { $0.isLetter || $0.isWhitespace }
        guard isValid else {
            errorMessage = "Name must contain letters and spaces only."
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                // 1. Update name via AuthStore (which updates Auth meta & profiles table)
                try await authStore.updateProfileName(to: trimmedName)
                
                // 2. Sync name back to PetStore user profile immediately
                petStore.currentUserProfile?.name = trimmedName
                
                isLoading = false
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}

#Preview {
    NamePromptSheet()
        .environment(AuthStore())
        .environment(PetStore())
}
