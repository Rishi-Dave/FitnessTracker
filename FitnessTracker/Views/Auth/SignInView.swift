// Views/Auth/SignInView.swift
import SwiftUI

struct SignInView: View {
    @EnvironmentObject var authService: AuthService
    @Binding var showSignUp: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showingVerification = false
    @State private var showingEmailCheck = false
    @State private var verificationEmail = ""
    
    var body: some View {
        Group {
            if showingVerification {
                EmailVerificationView(
                    email: verificationEmail,
                    isShowingVerification: $showingVerification
                )
                .environmentObject(authService)
            } else if showingEmailCheck {
                EmailCheckView(
                    isShowingEmailCheck: $showingEmailCheck,
                    onEmailVerified: { email in
                        verificationEmail = email
                        showingEmailCheck = false
                        showingVerification = true
                    }
                )
                .environmentObject(authService)
            } else {
                signInForm
            }
        }
    }
    
    private var signInForm: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // App Header
            VStack(spacing: 8) {
                Image(systemName: "figure.run.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Fitness Tracker")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Track your workouts with friends")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Sign In Form
            VStack(spacing: 16) {
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.password)
                
                // Error Message
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                
                // Sign In Button
                Button(action: signIn) {
                    if isLoading {
                        HStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                            Text("Signing In...")
                                .foregroundColor(.white)
                        }
                    } else {
                        Text("Sign In")
                    }
                }
                .disabled(isLoading || email.isEmpty || password.isEmpty)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(email.isEmpty || password.isEmpty ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                
                // Account Not Verified Button
                Button("Account not verified?") {
                    showingEmailCheck = true
                }
                .font(.subheadline)
                .foregroundColor(.orange)
                .padding(.top, 8)
                
                // Forgot Password (placeholder)
                Button("Forgot Password?") {
                    // TODO: Implement forgot password flow
                    print("Forgot password tapped")
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            Spacer()
            
            // Sign Up Link
            Button("Don't have an account? Sign Up") {
                showSignUp = true
            }
            .foregroundColor(.blue)
        }
        .padding()
    }
    
    // MARK: - Methods
    
    private func signIn() {
        guard !isLoading else { return }
        guard !email.isEmpty && !password.isEmpty else { return }
        
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                try await authService.signIn(email: email, password: password)
                
                await MainActor.run {
                    self.isLoading = false
                }
                
            } catch {
                await MainActor.run {
                    print("❌ Sign in error: \(error)")
                    let errorDescription = error.localizedDescription
                    
                    if errorDescription.contains("UserNotConfirmedException") ||
                       errorDescription.contains("not confirmed") ||
                       errorDescription.contains("User is not confirmed") {
                        
                        self.errorMessage = "Your email is not verified. Please use the 'Account not verified?' button below."
                        
                    } else if errorDescription.contains("NotAuthorizedException") ||
                              errorDescription.contains("Incorrect username or password") {
                        
                        self.errorMessage = "Invalid email or password. Please try again."
                        
                    } else if errorDescription.contains("UserNotFoundException") {
                        
                        self.errorMessage = "No account found with this email. Please sign up first."
                        
                    } else if errorDescription.contains("TooManyRequestsException") {
                        
                        self.errorMessage = "Too many sign-in attempts. Please wait a moment and try again."
                        
                    } else {
                        self.errorMessage = errorDescription
                    }
                    
                    self.isLoading = false
                }
            }
        }
    }
}

// MARK: - Email Check View

struct EmailCheckView: View {
    @Binding var isShowingEmailCheck: Bool
    let onEmailVerified: (String) -> Void
    @State private var email = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var successMessage = ""
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Header
            VStack(spacing: 16) {
                Image(systemName: "envelope.badge.person.crop")
                    .font(.system(size: 80))
                    .foregroundColor(.orange)
                
                Text("Account Verification")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Enter your email to verify your account")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // Email Input
            VStack(spacing: 16) {
                TextField("Enter your email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                
                // Success Message
                if !successMessage.isEmpty {
                    Text(successMessage)
                        .foregroundColor(.green)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                
                // Error Message
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                
                // Check Account Button
                Button(action: checkAccountAndSendCode) {
                    if isLoading {
                        HStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                            Text("Checking...")
                                .foregroundColor(.white)
                        }
                    } else {
                        Text("Send Verification Code")
                    }
                }
                .disabled(isLoading || email.isEmpty || !isValidEmail)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(email.isEmpty || !isValidEmail ? Color.gray : Color.orange)
                .foregroundColor(.white)
                .cornerRadius(12)
                
                // Info Text
                Text("We'll check if your account exists and send a verification code to your email.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // Back Button
            Button("Back to Sign In") {
                isShowingEmailCheck = false
            }
            .foregroundColor(.blue)
        }
        .padding()
    }
    
    private var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func checkAccountAndSendCode() {
        guard !email.isEmpty && isValidEmail else { return }
        
        isLoading = true
        errorMessage = ""
        successMessage = ""
        
        Task {
            do {
                // Try to resend verification code
                // If the account exists and is unverified, this will work
                // If the account doesn't exist or is already verified, it will fail
                try await authService.resendSignUpCode(username: email)
                
                await MainActor.run {
                    self.successMessage = "Verification code sent! Redirecting to verification..."
                    self.isLoading = false
                }
                
                // Wait a moment to show success message
                try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
                
                await MainActor.run {
                    onEmailVerified(email)
                }
                
            } catch {
                await MainActor.run {
                    let errorDescription = error.localizedDescription
                    
                    if errorDescription.contains("UserNotFoundException") {
                        self.errorMessage = "No account found with this email. Please sign up first."
                    } else if errorDescription.contains("InvalidParameterException") ||
                              errorDescription.contains("already confirmed") {
                        self.errorMessage = "This account is already verified. You can sign in normally."
                    } else if errorDescription.contains("LimitExceededException") {
                        self.errorMessage = "Too many requests. Please wait before trying again."
                    } else {
                        self.errorMessage = "Unable to send verification code. Please try again or contact support."
                    }
                    
                    self.isLoading = false
                }
            }
        }
    }
}

// MARK: - Preview
struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView(showSignUp: .constant(false))
            .environmentObject(AuthService())
    }
}
