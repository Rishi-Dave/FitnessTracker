// ContentView.swift
import SwiftUI

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var workoutService = WorkoutService()
    @StateObject private var authService = AuthService()
    @State private var selectedTab = 0
    @State private var showingTestView = false
    
    var body: some View {
        Group {
            if authService.isSignedIn {
                mainTabView
            } else {
                AuthenticationView()
                    .environmentObject(authService)
            }
        }
        .environmentObject(locationManager)
        .environmentObject(workoutService)
        .onAppear {
            setupMockData()
        }
        .sheet(isPresented: $showingTestView) {
            AWSTestView()
        }
    }
    
    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            WorkoutView()
                .tabItem {
                    Image(systemName: "figure.run")
                    Text("Workout")
                }
                .tag(0)
                .environmentObject(workoutService)
                .environmentObject(locationManager)
            
            HistoryView()
                .tabItem {
                    Image(systemName: "clock")
                    Text("History")
                }
                .tag(1)
                .environmentObject(workoutService)
            
            FriendsView()
                .tabItem {
                    Image(systemName: "person.2")
                    Text("Friends")
                }
                .tag(2)
                .environmentObject(workoutService)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
                .tag(3)
                .environmentObject(authService)
            
            #if DEBUG
            DebugView(showingTestView: $showingTestView)
                .tabItem {
                    Image(systemName: "hammer")
                    Text("Debug")
                }
                .tag(4)
                .environmentObject(workoutService)
            #endif
        }
    }
    
    private func setupMockData() {
        // Only load mock data if not using real AWS backend
        Task {
            do {
                // Load workout history
                _ = try await workoutService.fetchWorkoutHistory()
                
                // Load active friends workouts
                _ = try await workoutService.fetchActiveFriendsWorkouts()
                
                // Start friends subscription for real-time updates
                workoutService.subscribeToFriendsWorkouts()
                
                print("✅ Data loaded successfully")
            } catch {
                print("❌ Error loading data: \(error)")
            }
        }
    }
}

#if DEBUG
struct DebugView: View {
    @Binding var showingTestView: Bool
    @EnvironmentObject var workoutService: WorkoutService
    @State private var showingClearAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "hammer.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    
                    Text("Debug Menu")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Development tools and testing")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Debug Actions
                VStack(spacing: 16) {
                    
                    // Test AWS Backend
                    Button(action: {
                        showingTestView = true
                    }) {
                        HStack {
                            Image(systemName: "network")
                            Text("Test AWS Backend")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    
                    // Mock Data Toggle Info
                    VStack(spacing: 8) {
                        Text("Mock Data Mode")
                            .font(.headline)
                        
                        Text("Currently using: Mock Data")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                        
                        Text("To use AWS: Set useMockData = false in WorkoutService")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Clear Data
                    Button(action: {
                        showingClearAlert = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Clear All Data")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.red)
                        .cornerRadius(12)
                    }
                    
                    // App Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text("App Information")
                            .font(.headline)
                        
                        InfoRow(title: "Bundle ID", value: Bundle.main.bundleIdentifier ?? "Unknown")
                        InfoRow(title: "Version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")
                        InfoRow(title: "Build", value: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown")
                        InfoRow(title: "iOS Version", value: UIDevice.current.systemVersion)
                        InfoRow(title: "Device", value: UIDevice.current.model)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Debug")
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert("Clear All Data", isPresented: $showingClearAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                clearAllData()
            }
        } message: {
            Text("This will clear all workout history and active sessions. This action cannot be undone.")
        }
    }
    
    private func clearAllData() {
        Task {
            await MainActor.run {
                workoutService.workoutHistory.removeAll()
                workoutService.activeWorkouts.removeAll()
                workoutService.currentWorkoutSession = nil
                workoutService.isTracking = false
                print("🗑️ All local data cleared")
            }
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}
#endif
