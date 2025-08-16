import Amplify
import AWSCognitoAuthPlugin
import SwiftUI

@MainActor
class AuthService: ObservableObject {
    @Published var isSignedIn = false
    @Published var currentUser: AuthUser?
    
    init() {
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        Task {
            do {
                let session = try await Amplify.Auth.fetchAuthSession()
                self.isSignedIn = session.isSignedIn
            } catch {
                print("Error checking auth status: \(error)")
                self.isSignedIn = false
            }
        }
    }
    
    func signUp(email: String, password: String, name: String) async throws {
        let userAttributes = [
            AuthUserAttribute(.email, value: email),
            AuthUserAttribute(.name, value: name)
        ]
        let options = AuthSignUpRequest.Options(userAttributes: userAttributes)
        
        let result = try await Amplify.Auth.signUp(
            username: email,
            password: password,
            options: options
        )
        
        print("Sign up result: \(result)")
    }
    
    func confirmSignUp(username: String, confirmationCode: String) async throws {
        print("🔐 Confirming sign up for: \(username)")
        
        let result = try await Amplify.Auth.confirmSignUp(
            for: username,
            confirmationCode: confirmationCode
        )
        
        print("✅ Confirmation result: \(result.isSignUpComplete)")
        
        if !result.isSignUpComplete {
            throw NSError(domain: "AuthError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Sign up confirmation incomplete"])
        }
    }
    
    func resendSignUpCode(username: String) async throws {
        print("📧 Resending verification code for: \(username)")
        try await Amplify.Auth.resendSignUpCode(for: username)
        print("✅ Verification code resent successfully")
    }
    
    func signIn(email: String, password: String) async throws {
        print("🔐 Starting sign in for: \(email)")
        
        let result = try await Amplify.Auth.signIn(
            username: email,
            password: password
        )
        
        print("✅ Sign in result: \(result.isSignedIn)")
        
        if result.isSignedIn {
            await getCurrentUser()
            self.isSignedIn = true
            print("🎯 Auth state updated successfully")
        } else {
            print("⚠️ Sign in requires additional steps: \(result.nextStep)")
            throw NSError(domain: "AuthError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Sign in requires additional steps"])
        }
    }
    
    func signOut() async {
        let result = await Amplify.Auth.signOut()
        self.isSignedIn = false
        self.currentUser = nil
        print("Sign out result: \(result)")
    }
    
    private func getCurrentUser() async {
        do {
            let user = try await Amplify.Auth.getCurrentUser()
            self.currentUser = user
        } catch {
            print("Error getting current user: \(error)")
            self.currentUser = nil
        }
    }
}
