// Views/Profile/ProfileView.swift - Connected to AWS
import SwiftUI
import Amplify

struct ProfileView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var workoutService: WorkoutService
    @State private var userProfile: UserProfile?
    @State private var isLoading = true
    @State private var showingSignOutAlert = false
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading profile...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let profile = userProfile {
                    profileContent(profile: profile)
                } else {
                    errorView
                }
            }
            .navigationTitle("Profile")
            .refreshable {
                await loadUserProfile()
            }
            .onAppear {
                Task {
                    await loadUserProfile()
                }
            }
            .alert("Sign Out", isPresented: $showingSignOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    Task {
                        await signOut()
                    }
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
                Button("Retry") {
                    Task {
                        await loadUserProfile()
                    }
                }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func profileContent(profile: UserProfile) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile Header
                VStack(spacing: 16) {
                    // Profile Picture
                    AsyncImage(url: URL(string: profile.profilePictureURL ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Circle()
                            .fill(Color.blue.gradient)
                            .overlay(
                                Text(profile.initials)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .shadow(radius: 5)
                    
                    // User Info
                    VStack(spacing: 4) {
                        Text(profile.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(profile.email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if let joinDate = profile.joinDate {
                            Text("Member since \(joinDate, style: .date)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                
                // Fitness Stats
                VStack(spacing: 16) {
                    Text("Fitness Stats")
                        .font(.headline)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        StatCard(
                            title: "Total Workouts",
                            value: "\(profile.totalWorkouts)",
                            icon: "figure.run",
                            color: .blue
                        )
                        
                        StatCard(
                            title: "Total Distance",
                            value: String(format: "%.1f km", profile.totalDistance),
                            icon: "location",
                            color: .green
                        )
                        
                        StatCard(
                            title: "Total Time",
                            value: formatTotalTime(profile.totalDuration),
                            icon: "clock",
                            color: .orange
                        )
                        
                        StatCard(
                            title: "Avg Distance",
                            value: profile.totalWorkouts > 0 ? String(format: "%.1f km", profile.totalDistance / Double(profile.totalWorkouts)) : "0 km",
                            icon: "chart.line.uptrend.xyaxis",
                            color: .purple
                        )
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                
                // Recent Activity
                if !workoutService.workoutHistory.isEmpty {
                    VStack(spacing: 16) {
                        HStack {
                            Text("Recent Activity")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            NavigationLink("View All", destination: EmptyView())
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                        
                        VStack(spacing: 12) {
                            ForEach(Array(workoutService.workoutHistory.prefix(3))) { workout in
                                RecentWorkoutRow(workout: workout)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                }
                
                // Account Actions
                VStack(spacing: 12) {
                    Text("Account")
                        .font(.headline)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 1) {
                        AccountActionRow(
                            icon: "person.circle",
                            title: "Edit Profile",
                            action: { print("Edit profile tapped") }
                        )
                        
                        AccountActionRow(
                            icon: "bell",
                            title: "Notifications",
                            action: { print("Notifications tapped") }
                        )
                        
                        AccountActionRow(
                            icon: "lock",
                            title: "Privacy & Security",
                            action: { print("Privacy tapped") }
                        )
                        
                        AccountActionRow(
                            icon: "questionmark.circle",
                            title: "Help & Support",
                            action: { print("Help tapped") }
                        )
                        
                        AccountActionRow(
                            icon: "arrow.right.square",
                            title: "Sign Out",
                            action: { showingSignOutAlert = true },
                            isDestructive: true
                        )
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                // App Info
                VStack(spacing: 8) {
                    Text("Fitness Tracker")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                       let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                        Text("Version \(version) (\(build))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 8)
                
                Spacer(minLength: 40)
            }
            .padding()
        }
    }
    
    private var errorView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Unable to Load Profile")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("There was an error loading your profile information.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Retry") {
                Task {
                    await loadUserProfile()
                }
            }
            .buttonStyle(.borderedProminent)
            
            Button("Sign Out") {
                showingSignOutAlert = true
            }
            .foregroundColor(.red)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Data Loading
    
    private func loadUserProfile() async {
        print("👤 Loading user profile...")
        
        await MainActor.run {
            isLoading = true
            errorMessage = ""
        }
        
        do {
            // Get current user from Amplify Auth
            let user = try await Amplify.Auth.getCurrentUser()
            print("👤 Current user: \(user.userId)")
            
            // Calculate stats from workout history
            let workouts = workoutService.workoutHistory
            let totalWorkouts = workouts.count
            let totalDistance = workouts.reduce(0) { $0 + $1.distance }
            let totalDuration = workouts.reduce(0) { $0 + $1.duration }
            
            // Get user attributes
            let attributes = try await Amplify.Auth.fetchUserAttributes()
            var name = "User"
            var email = user.username
            
            for attribute in attributes {
                switch attribute.key {
                case .name:
                    name = attribute.value
                case .email:
                    email = attribute.value
                default:
                    break
                }
            }
            
            let profile = UserProfile(
                id: user.userId,
                name: name,
                email: email,
                profilePictureURL: nil, // TODO: Implement profile pictures
                totalWorkouts: totalWorkouts,
                totalDistance: totalDistance,
                totalDuration: totalDuration,
                joinDate: nil // TODO: Get from user creation date
            )
            
            await MainActor.run {
                self.userProfile = profile
                self.isLoading = false
            }
            
            print("✅ Profile loaded: \(name) - \(totalWorkouts) workouts")
            
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to load profile: \(error.localizedDescription)"
                self.isLoading = false
                self.showingError = true
            }
            print("❌ Error loading profile: \(error)")
        }
    }
    
    private func signOut() async {
        print("👋 Signing out...")
        await authService.signOut()
    }
    
    // MARK: - Helper Methods
    
    private func formatTotalTime(_ totalSeconds: Int) -> String {
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - User Profile Model

struct UserProfile {
    let id: String
    let name: String
    let email: String
    let profilePictureURL: String?
    let totalWorkouts: Int
    let totalDistance: Double
    let totalDuration: Int
    let joinDate: Date?
    
    var initials: String {
        let components = name.components(separatedBy: " ")
        let firstInitial = components.first?.prefix(1).uppercased() ?? ""
        let lastInitial = components.count > 1 ? components.last?.prefix(1).uppercased() ?? "" : ""
        return "\(firstInitial)\(lastInitial)"
    }
}

// MARK: - Preview

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthService())
            .environmentObject(WorkoutService())
    }
}
