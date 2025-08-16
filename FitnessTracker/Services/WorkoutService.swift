import CoreLocation
import SwiftUI

@MainActor
class WorkoutService: ObservableObject {
    @Published var currentWorkoutSession: WorkoutSessionModel?
    @Published var isTracking = false
    @Published var workoutHistory: [WorkoutSessionModel] = []
    @Published var activeWorkouts: [ActiveWorkoutModel] = []
    
    init() {
        print("ðŸ”§ WorkoutService initialized in MOCK mode")
    }
    
    // MARK: - Workout Session Management
    
    func startWorkout() async throws {
        print("Starting new workout session...")
        
        let userId = getCurrentUserId()
        
        let workoutSession = WorkoutSessionModel(
            userId: userId,
            startTime: Date(),
            distance: 0,
            duration: 0,
            isActive: true
        )
        
        // Mock implementation with delay
        try await mockDelay()
        self.currentWorkoutSession = workoutSession
        self.isTracking = true
        print("Mock workout session started: \(workoutSession.id)")
    }
    
    func updateWorkoutMetrics(distance: Double, duration: Int) async throws {
        guard var session = currentWorkoutSession else {
            print("No active workout session to update")
            return
        }
        
        session.distance = distance
        session.duration = duration
        
        // Mock implementation
        self.currentWorkoutSession = session
        print("Mock workout metrics updated: \(distance)km, \(duration)s")
    }
    
    func endWorkout() async throws {
        guard var session = currentWorkoutSession else {
            print("¸ No active workout session to end")
            return
        }
        
        session.endTime = Date()
        session.isActive = false
        
        // Mock implementation
        try await mockDelay()
        self.currentWorkoutSession = nil
        self.isTracking = false
        self.workoutHistory.insert(session, at: 0) // Add to history
        print("Mock workout session ended: \(session.id)")
        
        // Trigger post-workout processing
        await triggerWorkoutProcessing(sessionId: session.id)
    }
    
    func pauseWorkout() {
        self.isTracking = false
        print("Workout tracking paused")
    }
    
    func resumeWorkout() {
        guard currentWorkoutSession != nil else {
            print("No workout session to resume")
            return
        }
        
        self.isTracking = true
        print("Workout tracking resumed")
    }
    
    // MARK: - Location Data Management
    
    func addLocationData(_ location: CLLocation, sessionId: String) async throws {
        let locationData = LocationDataModel(
            sessionId: sessionId,
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            altitude: location.altitude,
            timestamp: Date()
        )
        
        // Mock implementation - just log
        print("Mock location saved: \(locationData.latitude), \(locationData.longitude)")
    }
    
    // MARK: - Workout History
    
    func fetchWorkoutHistory() async throws -> [WorkoutSessionModel] {
        print("ðŸ“š Fetching workout history...")
        
        // Return mock data
        let mockWorkouts = generateMockWorkoutHistory()
        self.workoutHistory = mockWorkouts
        return mockWorkouts
    }
    
    // MARK: - Friends & Social Features
    
    func subscribeToFriendsWorkouts() {
        print("ðŸ‘¥ Setting up friends workout subscription...")
        
        // Mock implementation with timer
        startMockFriendsUpdates()
    }
    
    func fetchActiveFriendsWorkouts() async throws -> [ActiveWorkoutModel] {
        print("ðŸ” Fetching active friends workouts...")
        
        let mockActive = generateMockActiveWorkouts()
        self.activeWorkouts = mockActive
        return mockActive
    }
    
    // MARK: - Private Helper Methods
    
    private func getCurrentUserId() -> String {
        // Mock user ID for now
        return "mock-user-\(UUID().uuidString.prefix(8))"
    }
    
    private func triggerWorkoutProcessing(sessionId: String) async {
        print("âš™ï¸ Triggering post-workout processing for: \(sessionId)")
        
        // Mock processing delay
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        print("âœ… Mock workout processing completed")
    }
    
    private func handleFriendLocationUpdate(_ locationData: LocationDataModel) async {
        print("ðŸ“ Friend location update received")
        
        await MainActor.run {
            NotificationCenter.default.post(
                name: .friendLocationUpdate,
                object: locationData
            )
        }
    }
    
    private func startMockFriendsUpdates() {
        Task {
            while true {
                try await Task.sleep(nanoseconds: 15_000_000_000) // 15 seconds
                
                let mockLocation = LocationDataModel(
                    sessionId: "mock-friend-session",
                    latitude: 37.7749 + Double.random(in: -0.01...0.01),
                    longitude: -122.4194 + Double.random(in: -0.01...0.01),
                    altitude: Double.random(in: 0...100),
                    timestamp: Date()
                )
                
                await handleFriendLocationUpdate(mockLocation)
            }
        }
    }
    
    private func mockDelay() async throws {
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
    }
}

// MARK: - Mock Data Generation

extension WorkoutService {
    
    private func generateMockWorkoutHistory() -> [WorkoutSessionModel] {
        return [
            WorkoutSessionModel(
                userId: getCurrentUserId(),
                startTime: Date().addingTimeInterval(-86400), // Yesterday
                endTime: Date().addingTimeInterval(-82800),   // 1 hour later
                distance: 5.2,
                duration: 1800, // 30 minutes
                averagePace: 5.77, // min/km
                totalElevationGain: 45.0,
                isActive: false
            ),
            WorkoutSessionModel(
                userId: getCurrentUserId(),
                startTime: Date().addingTimeInterval(-172800), // 2 days ago
                endTime: Date().addingTimeInterval(-169200),   // 1 hour later
                distance: 3.1,
                duration: 1200, // 20 minutes
                averagePace: 6.45,
                totalElevationGain: 23.0,
                isActive: false
            ),
            WorkoutSessionModel(
                userId: getCurrentUserId(),
                startTime: Date().addingTimeInterval(-259200), // 3 days ago
                endTime: Date().addingTimeInterval(-255600),   // 1 hour later
                distance: 8.7,
                duration: 2700, // 45 minutes
                averagePace: 5.17,
                totalElevationGain: 78.0,
                isActive: false
            )
        ]
    }
    
    private func generateMockActiveWorkouts() -> [ActiveWorkoutModel] {
        return [
            ActiveWorkoutModel(
                userId: "friend1",
                userName: "Sarah Wilson",
                userProfilePic: "",
                currentDistance: 2.3,
                currentDuration: 890,
                startTime: Date().addingTimeInterval(-890)
            ),
            ActiveWorkoutModel(
                userId: "friend2",
                userName: "Mike Johnson",
                userProfilePic: "",
                currentDistance: 4.1,
                currentDuration: 1456,
                startTime: Date().addingTimeInterval(-1456)
            )
        ]
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let friendLocationUpdate = Notification.Name("friendLocationUpdate")
    static let workoutSessionStarted = Notification.Name("workoutSessionStarted")
    static let workoutSessionEnded = Notification.Name("workoutSessionEnded")
}
