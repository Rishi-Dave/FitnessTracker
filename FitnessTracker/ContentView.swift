// ContentView.swift
import SwiftUI

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var workoutService = WorkoutService()
    @EnvironmentObject var authService: AuthService  // Added: Get authService from environment
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            WorkoutView()
                .tabItem {
                    Image(systemName: "figure.run")
                    Text("Workout")
                }
                .tag(0)
                .environmentObject(workoutService)
            
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
                .environmentObject(workoutService)
                .environmentObject(authService)  // Added: Pass authService to ProfileView
        }
        .environmentObject(locationManager)
        .onAppear {
            setupMockData()
        }
    }
    
    private func setupMockData() {
        // Load initial mock data when ContentView appears
        Task {
            do {
                // Load workout history
                _ = try await workoutService.fetchWorkoutHistory()
                
                // Load active friends workouts
                _ = try await workoutService.fetchActiveFriendsWorkouts()
                
                // Start friends subscription for real-time updates
                workoutService.subscribeToFriendsWorkouts()
                
                print("✅ Mock data loaded successfully")
            } catch {
                print("❌ Error loading mock data: \(error)")
            }
        }
    }
}
