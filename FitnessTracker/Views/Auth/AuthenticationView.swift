//
//  AuthenticationView.swift
//  FitnessTracker
//
//  Created by Rishi Dave on 8/16/25.
//

import SwiftUI

struct AuthenticationView: View {
    @StateObject private var authService = AuthService()
    @State private var showSignUp = false
    
    var body: some View {
        VStack {
            // Debug header - KEEP THIS for now
            HStack {
                Text("Auth Status: \(authService.isSignedIn ? "✅ SIGNED IN" : "❌ NOT SIGNED IN")")
                    .font(.caption)
                    .foregroundColor(authService.isSignedIn ? .green : .red)
                    .padding(4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(4)
                
                Spacer()
                
                Button("Check Status") {
                    authService.checkAuthStatus()
                }
                .font(.caption)
            }
            .padding(.horizontal)
            
            // Main content
            Group {
                if authService.isSignedIn {
                    ContentView()
                        .environmentObject(authService)
                } else {
                    if showSignUp {
                        SignUpView(showSignUp: $showSignUp)
                            .environmentObject(authService)
                    } else {
                        SignInView(showSignUp: $showSignUp)
                            .environmentObject(authService)
                    }
                }
            }
        }
        .onAppear {
            print("🔍 AuthenticationView appeared")
            authService.checkAuthStatus()
        }
        .onChange(of: authService.isSignedIn) {
            print("🔄 Auth state changed to: \(authService.isSignedIn)")
        }
    }
}
