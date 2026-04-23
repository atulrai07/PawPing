//
//  AuthModel.swift
//  PawPing
//
//  Created by Antigravity on 23/04/26.
//
//  Data models for the authentication flow.
//  These are plain types — no @Observable needed because
//  the AuthStore holds them and SwiftUI tracks changes at the store level.
//

import Foundation

// MARK: - Auth Route

/// All possible navigation destinations inside the auth flow.
/// Used with NavigationStack's navigationDestination(for:) for type-safe routing.
enum AuthRoute: Hashable {
    case createAccount
    case otp(context: OTPContext)
    case setDetails
    case setProfile
    case forgotPassword
    case forgotOTP
    case forgotSetPassword
}

// MARK: - OTP Context

/// Distinguishes which flow triggered the OTP screen
/// so we can navigate to the correct next step.
enum OTPContext: Hashable {
    case createAccount
    case forgotPassword
}

// MARK: - Password Validation Rule

/// A single rule shown below the password field with a pass/fail indicator.
struct PasswordRule: Identifiable {
    let id = UUID()
    let label: String
    let isMet: Bool
}

// MARK: - Dog Breed

/// Common breeds for the picker dropdown.
/// Uses CaseIterable so we can iterate in a Picker or Menu.
enum DogBreed: String, CaseIterable, Hashable {
    case labrador    = "Labrador"
    case goldenRetriever = "Golden Retriever"
    case germanShepherd  = "German Shepherd"
    case bulldog     = "Bulldog"
    case poodle      = "Poodle"
    case beagle      = "Beagle"
    case rottweiler  = "Rottweiler"
    case husky       = "Husky"
    case dachshund   = "Dachshund"
    case boxer       = "Boxer"
    case pug         = "Pug"
    case shihTzu     = "Shih Tzu"
    case indie       = "Indie"
    case other       = "Other"
}

// MARK: - Neutered Status

enum NeuteredStatus: String, CaseIterable, Hashable {
    case yes = "Yes"
    case no  = "No"
}
