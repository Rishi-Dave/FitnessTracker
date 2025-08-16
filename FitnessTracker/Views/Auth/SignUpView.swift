// Views/Auth/SignUpView.swift
import SwiftUI
import Amplify

struct SignUpView: View {
    @EnvironmentObject var authService: AuthService
    @Binding var showSignUp: Bool
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showingVerification = false
    @State private var signUpEmail = ""
    
    var body: some View {
        Group {
            if showingVerification {
                EmailVerificationView(
                    email: signUpEmail,
                    isShowingVerification: $showingVerification,
                )
                .environmentObject(authService)
            } else {
                signUpForm
            }
        }
    }
    
    private var signUpForm: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Header
            Text("Create Account")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Join the fitness community")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            // Form Fields
            VStack(spacing: 16) {
                TextField("Full Name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.words)
                
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                // Password Requirements
                VStack(alignment: .leading, spacing: 4) {
                    Text("Password requirements:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: password.count >= 8 ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(password.count >= 8 ? .green : .gray)
                        Text("At least 8 characters")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    
                    HStack {
                        Image(systemName: containsUppercase ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(containsUppercase ? .green : .gray)
                        Text("One uppercase letter")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    
                    HStack {
                        Image(systemName: containsNumber ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(containsNumber ? .green : .gray)
                        Text("One number")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    
                    HStack {
                        Image(systemName: passwordsMatch ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(passwordsMatch ? .green : .gray)
                        Text("Passwords match")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
                .padding(.horizontal, 4)
                
                // Error Message
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                
                // Sign Up Button
                Button(action: signUp) {
                    if isLoading {
                        HStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                            Text("Creating Account...")
                                .foregroundColor(.white)
                        }
                    } else {
                        Text("Sign Up")
                    }
                }
                .disabled(isLoading || !isFormValid)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(isFormValid ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(12)
                
                // Terms and Privacy
                Text("By signing up, you agree to our Terms of Service and Privacy Policy")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // Back to Sign In
            Button("Already have an account? Sign In") {
                showSignUp = false
            }
            .foregroundColor(.blue)
        }
        .padding()
    }
    
    // MARK: - Computed Properties
    
    private var isFormValid: Bool {
        !name.isEmpty &&
        !email.isEmpty &&
        isValidEmail &&
        password.count >= 8 &&
        containsUppercase &&
        containsNumber &&
        passwordsMatch
    }
    
    private var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private var containsUppercase: Bool {
        password.rangeOfCharacter(from: .uppercaseLetters) != nil
    }
    
    private var containsNumber: Bool {
        password.rangeOfCharacter(from: .decimalDigits) != nil
    }
    
    private var passwordsMatch: Bool {
        !password.isEmpty && password == confirmPassword
    }
    
    // MARK: - Methods
    
    private func signUp() {
        guard isFormValid else { return }
        
        isLoading = true
        errorMessage = ""
        signUpEmail = email
        
        Task {
            do {
                try await authService.signUp(email: email, password: password, name: name)
                
                await MainActor.run {
                    print("✅ Sign up successful, showing verification view")
                    self.showingVerification = true
                    self.isLoading = false
                }
                
            } catch {
                await MainActor.run {
                    print("❌ Sign up error: \(error)")
                    self.errorMessage = parseAuthError(error)
                    self.isLoading = false
                }
            }
        }
    }
    
    private func parseAuthError(_ error: Error) -> String {
        // Simple approach - just use the error description
        let errorString = error.localizedDescription.lowercased()
        
        if errorString.contains("usernameexists") || errorString.contains("already exists") {
            return "An account with this email already exists"
        } else if errorString.contains("invalidpassword") || errorString.contains("password") {
            return "Password doesn't meet requirements"
        } else if errorString.contains("invalidparameter") || errorString.contains("invalid email") {
            return "Please check your email format"
        } else if errorString.contains("usernotfound") {
            return "Account not found"
        } else if errorString.contains("notauthorized") {
            return "Invalid email or password"
        }
        
        return error.localizedDescription
    }

    private func parseVerificationError(_ error: Error) -> String {
        let errorString = error.localizedDescription.lowercased()
        
        if errorString.contains("codemismatch") || errorString.contains("invalid code") {
            return "Invalid verification code. Please try again."
        } else if errorString.contains("expiredcode") || errorString.contains("expired") {
            return "Verification code has expired. Please request a new one."
        } else if errorString.contains("limitexceeded") || errorString.contains("too many") {
            return "Too many attempts. Please wait before trying again."
        }
        
        return error.localizedDescription
    }}
