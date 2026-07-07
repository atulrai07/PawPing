import Foundation
import UIKit
import AuthenticationServices

class SignInWithAppleCoordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    let authStore: AuthStore
    let onError: (Error) -> Void
    let onSuccess: () -> Void
    
    init(authStore: AuthStore, onError: @escaping (Error) -> Void, onSuccess: @escaping () -> Void) {
        self.authStore = authStore
        self.onError = onError
        self.onSuccess = onSuccess
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
            ?? scenes.first as? UIWindowScene
        
        if let windowScene {
            return windowScene.windows.first(where: { $0.isKeyWindow }) ?? UIWindow(windowScene: windowScene)
        }
        if let fallbackScene = scenes.first as? UIWindowScene {
            return UIWindow(windowScene: fallbackScene)
        }
        return UIWindow()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            onError(NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid credential type"]))
            return
        }
        
        guard let tokenData = appleIDCredential.identityToken,
              let tokenString = String(data: tokenData, encoding: .utf8) else {
            onError(NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to retrieve Apple identity token"]))
            return
        }
        
        var fullNameString = ""
        if let name = appleIDCredential.fullName {
            let given = name.givenName ?? ""
            let family = name.familyName ?? ""
            fullNameString = "\(given) \(family)".trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        Task {
            do {
                try await authStore.signInWithApple(idToken: tokenString, fullName: fullNameString)
                onSuccess()
            } catch {
                onError(error)
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Suppress generic ASAuthorizationError.canceled to avoid annoying error popups when user cancels
        if let authError = error as? ASAuthorizationError, authError.code == .canceled {
            onSuccess()
            return
        }
        
        let nsError = error as NSError
        if nsError.domain == ASAuthorizationErrorDomain && nsError.code == ASAuthorizationError.Code.canceled.rawValue {
            onSuccess()
            return
        }
        
        if nsError.domain == "com.apple.AuthenticationServices.AuthorizationError" && nsError.code == 1000 {
            onSuccess()
            return
        }
        
        onError(error)
    }
}
