//
//  AuthStore.swift
//  PawPing
//
//  Created by Antigravity on 23/04/26.
//
//  The "brain" behind the authentication flow.
//  Holds all form state (email, password, OTP digits) and provides
//  computed validation properties.
//
//  Uses @Observable (iOS 17+) — same pattern as ActivityStore,
//  CareStore, and VaccineStore. Just change a var and SwiftUI reacts.
//

import Foundation
import Observation
import SwiftUI

@Observable
class AuthStore {

    // MARK: - Form State

    var email: String = ""
    var password: String = ""

    /// 4 individual OTP digit strings — each box holds one character.
    var otpDigits: [String] = ["", "", "", ""]

    var newPassword: String = ""
    var confirmPassword: String = ""

    /// Tracks which OTP box is currently focused.
    var focusedOTPIndex: Int? = 0

    // MARK: - Pet Profile Form State

    var petName: String = ""
    var petGender: DogGender = .male
    var petBreed: DogBreed = .labrador
    var petWeight: String = ""
    var petBirthday: Date = Date()
    var petNeutered: NeuteredStatus = .yes

    // MARK: - Navigation

    var path = NavigationPath()

    // MARK: - Email Validation

    /// Basic email format check using a simple regex.
    var isEmailValid: Bool {
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return email.range(of: pattern, options: .regularExpression) != nil
    }

    // MARK: - Password Validation Rules

    var hasMinLength: Bool {
        password.count >= 8
    }

    var hasSpecialCharacter: Bool {
        let specialChars = CharacterSet.punctuationCharacters
            .union(.symbols)
        return password.unicodeScalars.contains(where: { specialChars.contains($0) })
    }

    var passwordRules: [PasswordRule] {
        [
            PasswordRule(label: "Must be at least 8 Characters", isMet: hasMinLength),
            PasswordRule(label: "Must contain one special character", isMet: hasSpecialCharacter)
        ]
    }

    var isPasswordValid: Bool {
        hasMinLength && hasSpecialCharacter
    }

    // MARK: - New Password Validation (Forgot Password flow)

    var newHasMinLength: Bool {
        newPassword.count >= 8
    }

    var newHasSpecialCharacter: Bool {
        let specialChars = CharacterSet.punctuationCharacters
            .union(.symbols)
        return newPassword.unicodeScalars.contains(where: { specialChars.contains($0) })
    }

    var newPasswordRules: [PasswordRule] {
        [
            PasswordRule(label: "Must be at least 8 Characters", isMet: newHasMinLength),
            PasswordRule(label: "Must contain one special character", isMet: newHasSpecialCharacter)
        ]
    }

    var isNewPasswordValid: Bool {
        newHasMinLength && newHasSpecialCharacter
    }

    var doPasswordsMatch: Bool {
        !newPassword.isEmpty && newPassword == confirmPassword
    }

    // MARK: - OTP Validation

    /// All 4 digits must be filled.
    var isOTPComplete: Bool {
        otpDigits.allSatisfy { $0.count == 1 }
    }

    /// The combined 4-digit code.
    var otpCode: String {
        otpDigits.joined()
    }

    // MARK: - Masked Email

    /// Shows "a***@example.com" style masking for the OTP subtitle.
    var maskedEmail: String {
        guard let atIndex = email.firstIndex(of: "@") else { return email }
        let localPart = email[email.startIndex..<atIndex]
        let domain = email[atIndex...]

        if localPart.count <= 1 {
            return email
        }

        let firstChar = String(localPart.prefix(1))
        let maskedLocal = firstChar + String(repeating: "*", count: max(localPart.count - 1, 3))
        return maskedLocal + String(domain)
    }

    // MARK: - Actions (Stubbed)
    // These will be wired to a real backend later.
    // For now, they just navigate forward in the flow.

    func navigate(to route: AuthRoute) {
        path.append(route)
    }

    func popBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    func resetState() {
        email = ""
        password = ""
        otpDigits = ["", "", "", ""]
        newPassword = ""
        confirmPassword = ""
        focusedOTPIndex = 0
        path = NavigationPath()
    }
} // AuthStore
