// Services/WorkoutService.swift - Fixed AWS Implementation
import CoreLocation
import SwiftUI
import Amplify

@MainActor
class WorkoutService: ObservableObject {
    @Published var currentWorkoutSession: WorkoutSessionModel?
    @Published var isTracking = false
    @Published var workoutHistory: [WorkoutSessionModel] = []
    @Published var activeWorkouts: [ActiveWorkoutModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Set to false to use AWS, true for mock data
    private let useMockData = false
    
    init() {
        if useMockData {
            print("🎭 WorkoutService initialized in MOCK mode")
        } else {
            print("☁️ WorkoutService initialized in AWS mode")
        }
    }
    
    // MARK: - Workout Session Management
    
    func startWorkout() async throws {
        print("🏃‍♂️ Starting new workout session...")
        isLoading = true
        errorMessage = nil
        
        do {
            if useMockData {
                try await startWorkoutMock()
            } else {
                try await startWorkoutAWS()
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    func updateWorkoutMetrics(distance: Double, duration: Int) async throws {
        guard var session = currentWorkoutSession else {
            print("⚠️ No active workout session to update")
            return
        }
        
        session.distance = distance
        session.duration = duration
        
        if useMockData {
            self.currentWorkoutSession = session
            print("📊 Mock workout metrics updated: \(String(format: "%.2f", distance))km, \(duration)s")
        } else {
            try await updateWorkoutMetricsAWS(session: session)
        }
    }
    
    func endWorkout() async throws {
        guard var session = currentWorkoutSession else {
            print("⚠️ No active workout session to end")
            return
        }
        
        session.endTime = Date()
        session.isActive = false
        
        if useMockData {
            try await endWorkoutMock(session: session)
        } else {
            try await endWorkoutAWS(session: session)
        }
    }
    
    func pauseWorkout() {
        self.isTracking = false
        print("⏸️ Workout tracking paused")
    }
    
    func resumeWorkout() {
        guard currentWorkoutSession != nil else {
            print("⚠️ No workout session to resume")
            return
        }
        
        self.isTracking = true
        print("▶️ Workout tracking resumed")
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
        
        if useMockData {
            print("📍 Mock location saved: \(String(format: "%.6f", locationData.latitude)), \(String(format: "%.6f", locationData.longitude))")
        } else {
            try await addLocationDataAWS(locationData)
        }
    }
    
    // MARK: - AWS Implementation
    
    private func startWorkoutAWS() async throws {
        print("🔄 Creating AWS workout session...")
        
        guard let user = try? await Amplify.Auth.getCurrentUser() else {
            throw WorkoutError.authenticationRequired
        }
        
        // Create the workout session using proper JSON format
        let inputDict: [String: Any] = [
            "userId": user.userId,
            "startTime": ISO8601DateFormatter().string(from: Date()),
            "distance": 0.0,
            "duration": 0
        ]
        
        do {
            let request = GraphQLRequest<JSONValue>(
                document: CreateWorkoutSessionMutation.operationString,
                variables: ["input": inputDict],
                responseType: JSONValue.self
            )
            
            let result = try await Amplify.API.mutate(request: request)
            
            switch result {
            case .success(let data):
                print("📊 Raw GraphQL Response: \(data)")
                
                // Parse the JSON response manually
                if case .object(let dataObj) = data,
                   case .object(let createWorkoutSession) = dataObj["createWorkoutSession"],
                   case .string(let workoutId) = createWorkoutSession["id"],
                   case .string(let userId) = createWorkoutSession["userId"],
                   case .string(let startTimeString) = createWorkoutSession["startTime"] {
                    
                    let workoutSession = WorkoutSessionModel(
                        id: workoutId,
                        userId: userId,
                        startTime: ISO8601DateFormatter().date(from: startTimeString) ?? Date(),
                        endTime: nil,
                        distance: 0.0,
                        duration: 0,
                        isActive: true
                    )
                    
                    await MainActor.run {
                        self.currentWorkoutSession = workoutSession
                        self.isTracking = true
                        self.isLoading = false
                    }
                    
                    print("✅ AWS workout session created: \(workoutSession.id)")
                } else {
                    print("❌ Failed to parse workout response: \(data)")
                    throw WorkoutError.invalidResponse("Could not parse workout data from response")
                }
                
            case .failure(let error):
                print("❌ GraphQL Error: \(error)")
                throw WorkoutError.graphqlError(error.localizedDescription)
            }
            
        } catch let error as GraphQLError {
            print("❌ GraphQL Error Details: \(error)")
            throw WorkoutError.graphqlError(error.localizedDescription)
        } catch {
            print("❌ Failed to create AWS workout: \(error)")
            throw WorkoutError.networkError(error.localizedDescription)
        }
    }
    
    private func updateWorkoutMetricsAWS(session: WorkoutSessionModel) async throws {
        print("🔄 Updating AWS workout metrics...")
        
        let inputDict: [String: Any] = [
            "id": session.id,
            "distance": session.distance,
            "duration": session.duration
        ]
        
        do {
            let request = GraphQLRequest<JSONValue>(
                document: UpdateWorkoutSessionMutation.operationString,
                variables: ["input": inputDict],
                responseType: JSONValue.self
            )
            
            let result = try await Amplify.API.mutate(request: request)
            
            switch result {
            case .success(let data):
                print("📊 Update Response: \(data)")
                await MainActor.run {
                    if var currentSession = self.currentWorkoutSession {
                        currentSession.distance = session.distance
                        currentSession.duration = session.duration
                        self.currentWorkoutSession = currentSession
                    }
                }
                print("✅ AWS workout metrics updated")
                
            case .failure(let error):
                print("❌ Failed to update workout metrics: \(error)")
                throw WorkoutError.graphqlError(error.localizedDescription)
            }
            
        } catch {
            print("❌ Error updating workout metrics: \(error)")
            throw WorkoutError.networkError(error.localizedDescription)
        }
    }
    
    private func endWorkoutAWS(session: WorkoutSessionModel) async throws {
        print("🔄 Ending AWS workout session...")
        
        let inputDict: [String: Any] = [
            "id": session.id,
            "endTime": ISO8601DateFormatter().string(from: session.endTime ?? Date()),
            "distance": session.distance,
            "duration": session.duration
        ]
        
        do {
            let request = GraphQLRequest<JSONValue>(
                document: UpdateWorkoutSessionMutation.operationString,
                variables: ["input": inputDict],
                responseType: JSONValue.self
            )
            
            let result = try await Amplify.API.mutate(request: request)
            
            switch result {
            case .success(let data):
                print("📊 End Workout Response: \(data)")
                
                // Parse the response and create final workout
                if case .object(let dataObj) = data,
                   case .object(let updateWorkoutSession) = dataObj["updateWorkoutSession"],
                   case .string(let workoutId) = updateWorkoutSession["id"] {
                    
                    var finalWorkout = session
                    finalWorkout.isActive = false
                    
                    await MainActor.run {
                        self.currentWorkoutSession = nil
                        self.isTracking = false
                        self.workoutHistory.insert(finalWorkout, at: 0)
                    }
                    
                    print("✅ AWS workout session completed: \(finalWorkout.id)")
                } else {
                    print("❌ Failed to parse end workout response: \(data)")
                    throw WorkoutError.invalidResponse("Could not parse end workout response")
                }
                
            case .failure(let error):
                print("❌ Failed to end workout: \(error)")
                throw WorkoutError.graphqlError(error.localizedDescription)
            }
            
        } catch {
            print("❌ Error ending workout: \(error)")
            throw WorkoutError.networkError(error.localizedDescription)
        }
    }
    
    private func addLocationDataAWS(_ locationData: LocationDataModel) async throws {
        print("📍 Saving location to AWS...")
        
        let inputDict: [String: Any] = [
            "sessionId": locationData.sessionId,
            "latitude": locationData.latitude,
            "longitude": locationData.longitude,
            "altitude": locationData.altitude as Any,
            "timestamp": ISO8601DateFormatter().string(from: locationData.timestamp)
        ]
        
        do {
            let request = GraphQLRequest<JSONValue>(
                document: CreateLocationDataMutation.operationString,
                variables: ["input": inputDict],
                responseType: JSONValue.self
            )
            
            let result = try await Amplify.API.mutate(request: request)
            
            switch result {
            case .success(let data):
                print("📊 Location Save Response: \(data)")
                if case .object(let dataObj) = data,
                   case .object(let createLocationData) = dataObj["createLocationData"],
                   case .string(let locationId) = createLocationData["id"] {
                    print("✅ Location saved to AWS: \(locationId)")
                }
                
            case .failure(let error):
                print("❌ Failed to save location: \(error)")
                // Don't throw error for location saves to avoid interrupting workout
            }
            
        } catch {
            print("❌ Error saving location: \(error)")
            // Don't throw error for location saves
        }
    }
    
    private func fetchWorkoutHistoryAWS() async throws -> [WorkoutSessionModel] {
        print("📚 Fetching workout history from AWS...")
        
        guard let user = try? await Amplify.Auth.getCurrentUser() else {
            throw WorkoutError.authenticationRequired
        }
        
        do {
            // Simplified query without complex filters first
            let request = GraphQLRequest<JSONValue>(
                document: """
                query ListWorkoutSessions($limit: Int) {
                    listWorkoutSessions(limit: $limit) {
                        items {
                            id
                            userId
                            startTime
                            endTime
                            distance
                            duration
                            createdAt
                            updatedAt
                        }
                        nextToken
                    }
                }
                """,
                variables: ["limit": 50],
                responseType: JSONValue.self
            )
            
            let result = try await Amplify.API.query(request: request)
            
            switch result {
            case .success(let data):
                print("📊 Workout History Response: \(data)")
                
                var workouts: [WorkoutSessionModel] = []
                
                // Parse the JSON response manually
                if case .object(let dataObj) = data,
                   case .object(let listWorkoutSessions) = dataObj["listWorkoutSessions"],
                   case .array(let items) = listWorkoutSessions["items"] {
                    
                    for item in items {
                        if case .object(let workoutObj) = item,
                           case .string(let id) = workoutObj["id"],
                           case .string(let workoutUserId) = workoutObj["userId"],
                           case .string(let startTimeString) = workoutObj["startTime"] {
                            
                            // Only include workouts for the current user
                            guard workoutUserId == user.userId else { continue }
                            
                            // Extract optional fields safely
                            let endTimeString = workoutObj["endTime"] as? String
                            let distance = (workoutObj["distance"] as? NSNumber)?.doubleValue ?? 0.0
                            let duration = (workoutObj["duration"] as? NSNumber)?.intValue ?? 0
                            
                            // Parse dates
                            let startTime = ISO8601DateFormatter().date(from: startTimeString) ?? Date()
                            let endTime = endTimeString.flatMap { ISO8601DateFormatter().date(from: $0) }
                            
                            // Calculate additional metrics
                            let averagePace = duration > 0 && distance > 0 ? (Double(duration) / 60.0) / distance : nil
                            
                            let workout = WorkoutSessionModel(
                                id: id,
                                userId: workoutUserId,
                                startTime: startTime,
                                endTime: endTime,
                                distance: distance,
                                duration: duration,
                                averagePace: averagePace,
                                totalElevationGain: nil, // TODO: Add elevation to schema
                                isActive: endTime == nil // Active if no end time
                            )
                            
                            workouts.append(workout)
                            print("📝 Parsed workout: \(id) - \(distance)km, \(duration)s")
                        }
                    }
                    
                    // Sort by start time (newest first)
                    workouts.sort { $0.startTime > $1.startTime }
                    
                    await MainActor.run {
                        self.workoutHistory = workouts
                    }
                    
                    print("✅ Fetched \(workouts.count) workouts from AWS for user \(user.userId)")
                    return workouts
                    
                } else {
                    print("❌ Failed to parse workout history response: \(data)")
                    throw WorkoutError.invalidResponse("Could not parse workout history")
                }
                
            case .failure(let error):
                print("❌ Failed to fetch workout history: \(error)")
                throw WorkoutError.graphqlError(error.localizedDescription)
            }
            
        } catch {
            print("❌ Error fetching workout history: \(error)")
            throw WorkoutError.networkError(error.localizedDescription)
        }
    }
    
    // MARK: - Mock Implementation (fallback)
    
    private func startWorkoutMock() async throws {
        let userId = "mock-user-\(UUID().uuidString.prefix(8))"
        
        let workoutSession = WorkoutSessionModel(
            userId: userId,
            startTime: Date(),
            distance: 0,
            duration: 0,
            isActive: true
        )
        
        try await Task.sleep(nanoseconds: 500_000_000)
        
        self.currentWorkoutSession = workoutSession
        self.isTracking = true
        self.isLoading = false
        
        print("✅ Mock workout session started: \(workoutSession.id)")
    }
    
    private func endWorkoutMock(session: WorkoutSessionModel) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        self.currentWorkoutSession = nil
        self.isTracking = false
        self.workoutHistory.insert(session, at: 0)
        
        print("✅ Mock workout session ended: \(session.id)")
    }
    
    // MARK: - Friends & Social Features (simplified for now)
    
    func fetchWorkoutHistory() async throws -> [WorkoutSessionModel] {
        if useMockData {
            let mockWorkouts = generateMockWorkoutHistory()
            self.workoutHistory = mockWorkouts
            return mockWorkouts
        } else {
            return try await fetchWorkoutHistoryAWS()
        }
    }
    
    func subscribeToFriendsWorkouts() {
        print("👥 Setting up friends workout subscription...")
        // TODO: Implement AWS subscription for friends workouts
    }
    
    func fetchActiveFriendsWorkouts() async throws -> [ActiveWorkoutModel] {
        print("🔍 Fetching active friends workouts...")
        // For now, return empty array - implement later
        return []
    }
    
    // MARK: - Mock Data Generation
    
    private func generateMockWorkoutHistory() -> [WorkoutSessionModel] {
        return [
            WorkoutSessionModel(
                userId: "mock-user",
                startTime: Date().addingTimeInterval(-86400),
                endTime: Date().addingTimeInterval(-82800),
                distance: 5.2,
                duration: 1800,
                averagePace: 5.77,
                totalElevationGain: 45.0,
                isActive: false
            ),
            WorkoutSessionModel(
                userId: "mock-user",
                startTime: Date().addingTimeInterval(-172800),
                endTime: Date().addingTimeInterval(-169200),
                distance: 3.1,
                duration: 1200,
                averagePace: 6.45,
                totalElevationGain: 23.0,
                isActive: false
            )
        ]
    }
}

// MARK: - Custom Error Types

enum WorkoutError: LocalizedError {
    case authenticationRequired
    case invalidResponse(String)
    case graphqlError(String)
    case networkError(String)
    
    var errorDescription: String? {
        switch self {
        case .authenticationRequired:
            return "User authentication required"
        case .invalidResponse(let message):
            return "Invalid response: \(message)"
        case .graphqlError(let message):
            return "GraphQL error: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let friendLocationUpdate = Notification.Name("friendLocationUpdate")
    static let workoutSessionStarted = Notification.Name("workoutSessionStarted")
    static let workoutSessionEnded = Notification.Name("workoutSessionEnded")
}
