//
//  ProfileView.swift
//  FitnessTracker
//
//  Created by Rishi Dave on 8/16/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authService: AuthService  // Changed: Use environment object instead of creating new instance
    @State private var user: UserModel?
    @State private var showingSignOut = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(spacing: 16) {
                    AsyncImage(url: URL(string: user?.profilePicture ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                    }
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    
                    Text(user?.name ?? "User Name")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(user?.email ?? "user@example.com")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 30) {
                    StatView(title: "Total Workouts", value: "\(user?.totalWorkouts ?? 0)")
                    StatView(title: "Total Distance", value: String(format: "%.1f km", user?.totalDistance ?? 0))
                    StatView(title: "Friends", value: "\(user?.friendsCount ?? 0)")
                }
                
                Spacer()
                
                Button(action: { showingSignOut = true }) {
                    Text("Sign Out")
                        .font(.headline)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.red, lineWidth: 2)
                        )
                }
            }
            .padding()
            .navigationTitle("Profile")
            .onAppear {
                loadUserProfile()
            }
            .alert("Sign Out", isPresented: $showingSignOut) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    Task {
                        await authService.signOut()
                        // Removed duplicate checkAuthStatus call since signOut already updates isSignedIn
                        print("🚪 Sign out completed - UI should update immediately")
                    }
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }
    
    private func loadUserProfile() {
        // TODO: Load user profile from backend
        // For now, create mock user data
        self.user = UserModel(
            name: authService.currentUser?.username ?? "Demo User",
            email: "demo@example.com",
            profilePicture: "",
            totalWorkouts: 15,
            totalDistance: 125.3,
            friendsCount: 8,
            lastWorkoutDate: Date()
        )
    }
}
