// Views/Friends/FriendsView.swift
import SwiftUI

struct FriendsView: View {
    @EnvironmentObject var workoutService: WorkoutService
    @State private var friends: [UserModel] = []
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if isLoading {
                    ProgressView("Loading friends...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    mainContent
                }
            }
            .navigationTitle("Friends")
            .refreshable {
                await refreshData()
            }
            .onAppear {
                loadInitialData()
            }
        }
    }
    
    private var mainContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Active Workouts Section
                if !workoutService.activeWorkouts.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Friends Working Out")
                                .font(.headline)
                            
                            Spacer()
                            
                            Text("\(workoutService.activeWorkouts.count) active")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(workoutService.activeWorkouts) { workout in
                                    ActiveWorkoutCard(workout: workout)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                // Friends List Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("All Friends")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button("Add Friend") {
                            // TODO: Implement add friend functionality
                            print("Add friend tapped")
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                    .padding(.horizontal)
                    
                    if friends.isEmpty {
                        emptyFriendsView
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(friends) { friend in
                                FriendRowView(friend: friend)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                
                Spacer(minLength: 100)
            }
        }
    }
    
    private var emptyFriendsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2.circle")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Friends Yet")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("Add friends to see their workouts and compete together!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Find Friends") {
                // TODO: Implement friend discovery
                print("Find friends tapped")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private func loadInitialData() {
        isLoading = true
        
        Task {
            do {
                // Load active workouts
                _ = try await workoutService.fetchActiveFriendsWorkouts()
                
                // Load friends list (mock data)
                await loadMockFriends()
                
                await MainActor.run {
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    print("Error loading friends data: \(error)")
                    self.isLoading = false
                }
            }
        }
    }
    
    private func refreshData() async {
        do {
            _ = try await workoutService.fetchActiveFriendsWorkouts()
            await loadMockFriends()
        } catch {
            print("Error refreshing friends data: \(error)")
        }
    }
    
    private func loadMockFriends() async {
        // Simulate loading delay
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        let mockFriends = [
            UserModel(
                name: "John Doe",
                email: "john@example.com",
                profilePicture: "",
                totalWorkouts: 45,
                totalDistance: 234.5,
                friendsCount: 12,
                lastWorkoutDate: Date().addingTimeInterval(-86400) // Yesterday
            ),
            UserModel(
                name: "Sarah Wilson",
                email: "sarah@example.com",
                profilePicture: "",
                totalWorkouts: 67,
                totalDistance: 456.7,
                friendsCount: 23,
                lastWorkoutDate: Date().addingTimeInterval(-172800) // 2 days ago
            ),
            UserModel(
                name: "Mike Johnson",
                email: "mike@example.com",
                profilePicture: "",
                totalWorkouts: 23,
                totalDistance: 123.4,
                friendsCount: 8,
                lastWorkoutDate: Date().addingTimeInterval(-259200) // 3 days ago
            ),
            UserModel(
                name: "Emma Davis",
                email: "emma@example.com",
                profilePicture: "",
                totalWorkouts: 31,
                totalDistance: 187.2,
                friendsCount: 15,
                lastWorkoutDate: Date().addingTimeInterval(-345600) // 4 days ago
            )
        ]
        
        await MainActor.run {
            self.friends = mockFriends
        }
    }
}
