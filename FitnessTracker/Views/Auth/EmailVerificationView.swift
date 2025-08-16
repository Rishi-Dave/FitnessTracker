//
//  EmailVerificationView.swift
//  FitnessTracker
//
//  Created by Rishi Dave on 8/18/25.
//

// Create Views/Auth/EmailVerificationView.swift
import SwiftUI

struct EmailVerificationView: View {
    let email: String
    @State private var verificationCode = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @EnvironmentObject var authService: AuthService
    @Binding var isShowingVerification: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Verify Your Email")
                .font(.title)
                .fontWeight(.bold)
            
            Text("We sent a verification code to:")
                .foregroundColor(.secondary)
            
            Text(email)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
            
            TextField("Enter 6-digit code", text: $verificationCode)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .font(.title2)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button(action: confirmSignUp) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Verify")
                }
            }
            .disabled(verificationCode.count != 6 || isLoading)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(verificationCode.count != 6 ? Color.gray : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            
            Button("Resend Code") {
                Task {
                    await resendCode()
                }
            }
            .foregroundColor(.blue)
            
            Button("Back to Sign In") {
                isShowingVerification = false
            }
            .foregroundColor(.secondary)
        }
        .padding()
    }
    
    private func confirmSignUp() {
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                try await authService.confirmSignUp(username: email, confirmationCode: verificationCode)
                
                // After confirmation, try to sign in automatically
                await MainActor.run {
                    self.isShowingVerification = false
                    self.isLoading = false
                }
                
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    private func resendCode() async {
        do {
            try await authService.resendSignUpCode(username: email)
            errorMessage = "Code resent successfully!"
        } catch {
            errorMessage = "Failed to resend code: \(error.localizedDescription)"
        }
    }
}
