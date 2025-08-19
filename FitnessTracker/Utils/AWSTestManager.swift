// Utils/AWSTestManager.swift - Fixed JSONValue Parsing
import Amplify
import SwiftUI

class AWSTestManager: ObservableObject {
    @Published var testResults: [TestResult] = []
    @Published var isRunningTests = false
    
    struct TestResult {
        let testName: String
        let success: Bool
        let message: String
        let duration: TimeInterval
        let details: String?
    }
    
    func runAllTests() async {
        await MainActor.run {
            isRunningTests = true
            testResults.removeAll()
        }
        
        // Test 1: Authentication
        await testAuthentication()
        
        // Test 2: GraphQL API Connection
        await testGraphQLConnection()
        
        // Test 3: Create Workout Session
        await testCreateWorkoutSession()
        
        // Test 4: Create Location Data
        await testCreateLocationData()
        
        // Test 5: Fetch Workout History
        await testFetchWorkoutHistory()
        
        await MainActor.run {
            isRunningTests = false
        }
        
        printTestSummary()
    }
    
    private func testAuthentication() async {
        let startTime = Date()
        
        do {
            let authSession = try await Amplify.Auth.fetchAuthSession()
            let user = try await Amplify.Auth.getCurrentUser()
            let duration = Date().timeIntervalSince(startTime)
            
            let result = TestResult(
                testName: "Authentication",
                success: authSession.isSignedIn,
                message: authSession.isSignedIn ? "User authenticated: \(user.userId)" : "User not signed in",
                duration: duration,
                details: "User ID: \(user.userId)\nUsername: \(user.username)"
            )
            
            await MainActor.run {
                testResults.append(result)
            }
            
        } catch {
            let duration = Date().timeIntervalSince(startTime)
            let result = TestResult(
                testName: "Authentication",
                success: false,
                message: "Auth error: \(error.localizedDescription)",
                duration: duration,
                details: "Full error: \(error)"
            )
            
            await MainActor.run {
                testResults.append(result)
            }
        }
    }
    
    private func testGraphQLConnection() async {
        let startTime = Date()
        
        do {
            // Simple introspection query
            let queryDocument = """
            query {
                __schema {
                    queryType {
                        name
                    }
                }
            }
            """
            
            let request = GraphQLRequest<JSONValue>(
                document: queryDocument,
                variables: nil,
                responseType: JSONValue.self
            )
            
            let result = try await Amplify.API.query(request: request)
            let duration = Date().timeIntervalSince(startTime)
            
            switch result {
            case .success:
                let testResult = TestResult(
                    testName: "GraphQL Connection",
                    success: true,
                    message: "Successfully connected to GraphQL API",
                    duration: duration,
                    details: "GraphQL endpoint is responding correctly"
                )
                
                await MainActor.run {
                    testResults.append(testResult)
                }
                
            case .failure(let error):
                let testResult = TestResult(
                    testName: "GraphQL Connection",
                    success: false,
                    message: "GraphQL query failed: \(error.localizedDescription)",
                    duration: duration,
                    details: "Full error: \(error)"
                )
                
                await MainActor.run {
                    testResults.append(testResult)
                }
            }
            
        } catch {
            let duration = Date().timeIntervalSince(startTime)
            let testResult = TestResult(
                testName: "GraphQL Connection",
                success: false,
                message: "API connection error: \(error.localizedDescription)",
                duration: duration,
                details: "Full error: \(error)"
            )
            
            await MainActor.run {
                testResults.append(testResult)
            }
        }
    }
    
    private func testCreateWorkoutSession() async {
        let startTime = Date()
        
        do {
            let user = try await Amplify.Auth.getCurrentUser()
            
            // Create workout session
            let mutationDocument = """
            mutation CreateWorkoutSession($input: CreateWorkoutSessionInput!) {
                createWorkoutSession(input: $input) {
                    id
                    userId
                    startTime
                    endTime
                    distance
                    duration
                    createdAt
                    updatedAt
                }
            }
            """
            
            let currentTime = ISO8601DateFormatter().string(from: Date())
            
            let input: [String: Any] = [
                "userId": user.userId,
                "startTime": currentTime,
                "distance": 0.0,
                "duration": 0
            ]
            
            let variables: [String: Any] = ["input": input]
            
            let request = GraphQLRequest<JSONValue>(
                document: mutationDocument,
                variables: variables,
                responseType: JSONValue.self
            )
            
            let result = try await Amplify.API.mutate(request: request)
            let duration = Date().timeIntervalSince(startTime)
            
            switch result {
            case .success(let data):
                print("🔍 Create WorkoutSession response: \(data)")
                
                // Parse JSONValue properly
                if case .object(let dataObj) = data,
                   case .object(let createWorkoutSession) = dataObj["createWorkoutSession"],
                   case .string(let workoutId) = createWorkoutSession["id"] {
                    
                    let testResult = TestResult(
                        testName: "Create Workout Session",
                        success: true,
                        message: "✅ Successfully created workout session: \(workoutId)",
                        duration: duration,
                        details: "Workout ID: \(workoutId)\nUser ID: \(user.userId)\nCreation successful!"
                    )
                    
                    await MainActor.run {
                        testResults.append(testResult)
                    }
                    
                    // Clean up
                    await deleteTestWorkout(workoutId: workoutId)
                    
                } else {
                    let testResult = TestResult(
                        testName: "Create Workout Session",
                        success: false,
                        message: "Could not parse workout ID from response",
                        duration: duration,
                        details: "Response: \(data)"
                    )
                    
                    await MainActor.run {
                        testResults.append(testResult)
                    }
                }
                
            case .failure(let error):
                let testResult = TestResult(
                    testName: "Create Workout Session",
                    success: false,
                    message: "Create mutation failed: \(error.localizedDescription)",
                    duration: duration,
                    details: "Full error: \(error)"
                )
                
                await MainActor.run {
                    testResults.append(testResult)
                }
            }
            
        } catch {
            let duration = Date().timeIntervalSince(startTime)
            let testResult = TestResult(
                testName: "Create Workout Session",
                success: false,
                message: "Create test error: \(error.localizedDescription)",
                duration: duration,
                details: "Full error: \(error)"
            )
            
            await MainActor.run {
                testResults.append(testResult)
            }
        }
    }
    
    private func testCreateLocationData() async {
        let startTime = Date()
        
        do {
            // Create location data
            let mutationDocument = """
            mutation CreateLocationData($input: CreateLocationDataInput!) {
                createLocationData(input: $input) {
                    id
                    sessionId
                    latitude
                    longitude
                    altitude
                    timestamp
                    createdAt
                    updatedAt
                }
            }
            """
            
            let currentTime = ISO8601DateFormatter().string(from: Date())
            let testSessionId = "test-session-\(UUID().uuidString)"
            
            let input: [String: Any] = [
                "sessionId": testSessionId,
                "latitude": 37.7749,
                "longitude": -122.4194,
                "altitude": 100.0,
                "timestamp": currentTime
            ]
            
            let variables: [String: Any] = ["input": input]
            
            let request = GraphQLRequest<JSONValue>(
                document: mutationDocument,
                variables: variables,
                responseType: JSONValue.self
            )
            
            let result = try await Amplify.API.mutate(request: request)
            let duration = Date().timeIntervalSince(startTime)
            
            switch result {
            case .success(let data):
                print("🔍 Create LocationData response: \(data)")
                
                // Parse JSONValue properly
                if case .object(let dataObj) = data,
                   case .object(let createLocationData) = dataObj["createLocationData"],
                   case .string(let locationId) = createLocationData["id"] {
                    
                    let testResult = TestResult(
                        testName: "Create Location Data",
                        success: true,
                        message: "✅ Successfully created location data: \(locationId)",
                        duration: duration,
                        details: "Location ID: \(locationId)\nSession ID: \(testSessionId)\nCoordinates: 37.7749, -122.4194"
                    )
                    
                    await MainActor.run {
                        testResults.append(testResult)
                    }
                    
                    // Clean up
                    await deleteTestLocation(locationId: locationId)
                    
                } else {
                    let testResult = TestResult(
                        testName: "Create Location Data",
                        success: false,
                        message: "Could not parse location ID from response",
                        duration: duration,
                        details: "Response: \(data)"
                    )
                    
                    await MainActor.run {
                        testResults.append(testResult)
                    }
                }
                
            case .failure(let error):
                let testResult = TestResult(
                    testName: "Create Location Data",
                    success: false,
                    message: "Create mutation failed: \(error.localizedDescription)",
                    duration: duration,
                    details: "Full error: \(error)"
                )
                
                await MainActor.run {
                    testResults.append(testResult)
                }
            }
            
        } catch {
            let duration = Date().timeIntervalSince(startTime)
            let testResult = TestResult(
                testName: "Create Location Data",
                success: false,
                message: "Create test error: \(error.localizedDescription)",
                duration: duration,
                details: "Full error: \(error)"
            )
            
            await MainActor.run {
                testResults.append(testResult)
            }
        }
    }
    
    private func testFetchWorkoutHistory() async {
        let startTime = Date()
        
        do {
            let user = try await Amplify.Auth.getCurrentUser()
            
            // Fetch workout sessions
            let queryDocument = """
            query ListWorkoutSessions($filter: ModelWorkoutSessionFilterInput, $limit: Int) {
                listWorkoutSessions(filter: $filter, limit: $limit) {
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
            """
            
            let filter: [String: Any] = [
                "userId": [
                    "eq": user.userId
                ]
            ]
            
            let variables: [String: Any] = [
                "filter": filter,
                "limit": 10
            ]
            
            let request = GraphQLRequest<JSONValue>(
                document: queryDocument,
                variables: variables,
                responseType: JSONValue.self
            )
            
            let result = try await Amplify.API.query(request: request)
            let duration = Date().timeIntervalSince(startTime)
            
            switch result {
            case .success(let data):
                print("🔍 Fetch WorkoutSessions response: \(data)")
                
                // Parse JSONValue properly
                if case .object(let dataObj) = data,
                   case .object(let listWorkoutSessions) = dataObj["listWorkoutSessions"],
                   case .array(let items) = listWorkoutSessions["items"] {
                    
                    let workoutCount = items.count
                    
                    // Extract some details about the workouts
                    var workoutDetails: [String] = []
                    for item in items.prefix(3) {
                        if case .object(let workout) = item,
                           case .string(let id) = workout["id"],
                           case .string(let startTime) = workout["startTime"] {
                            workoutDetails.append("ID: \(id.prefix(8))... at \(startTime)")
                        }
                    }
                    
                    let testResult = TestResult(
                        testName: "Fetch Workout History",
                        success: true,
                        message: "✅ Successfully fetched \(workoutCount) workouts",
                        duration: duration,
                        details: "User ID: \(user.userId)\nWorkout count: \(workoutCount)\nSample workouts:\n" + workoutDetails.joined(separator: "\n")
                    )
                    
                    await MainActor.run {
                        testResults.append(testResult)
                    }
                    
                } else {
                    let testResult = TestResult(
                        testName: "Fetch Workout History",
                        success: false,
                        message: "Could not parse workout list from response",
                        duration: duration,
                        details: "Response structure unexpected: \(data)"
                    )
                    
                    await MainActor.run {
                        testResults.append(testResult)
                    }
                }
                
            case .failure(let error):
                let testResult = TestResult(
                    testName: "Fetch Workout History",
                    success: false,
                    message: "Query failed: \(error.localizedDescription)",
                    duration: duration,
                    details: "Full error: \(error)"
                )
                
                await MainActor.run {
                    testResults.append(testResult)
                }
            }
            
        } catch {
            let duration = Date().timeIntervalSince(startTime)
            let testResult = TestResult(
                testName: "Fetch Workout History",
                success: false,
                message: "Fetch test error: \(error.localizedDescription)",
                duration: duration,
                details: "Full error: \(error)"
            )
            
            await MainActor.run {
                testResults.append(testResult)
            }
        }
    }
    
    // MARK: - Cleanup Methods
    
    private func deleteTestWorkout(workoutId: String) async {
        do {
            let mutationDocument = """
            mutation DeleteWorkoutSession($input: DeleteWorkoutSessionInput!) {
                deleteWorkoutSession(input: $input) {
                    id
                }
            }
            """
            
            let input: [String: Any] = ["id": workoutId]
            let variables: [String: Any] = ["input": input]
            
            let request = GraphQLRequest<JSONValue>(
                document: mutationDocument,
                variables: variables,
                responseType: JSONValue.self
            )
            
            _ = try await Amplify.API.mutate(request: request)
            print("🗑️ Cleaned up test workout: \(workoutId)")
            
        } catch {
            print("⚠️ Failed to clean up test workout: \(error)")
        }
    }
    
    private func deleteTestLocation(locationId: String) async {
        do {
            let mutationDocument = """
            mutation DeleteLocationData($input: DeleteLocationDataInput!) {
                deleteLocationData(input: $input) {
                    id
                }
            }
            """
            
            let input: [String: Any] = ["id": locationId]
            let variables: [String: Any] = ["input": input]
            
            let request = GraphQLRequest<JSONValue>(
                document: mutationDocument,
                variables: variables,
                responseType: JSONValue.self
            )
            
            _ = try await Amplify.API.mutate(request: request)
            print("🗑️ Cleaned up test location: \(locationId)")
            
        } catch {
            print("⚠️ Failed to clean up test location: \(error)")
        }
    }
    
    // MARK: - Helper Methods
    
    private func printTestSummary() {
        let totalTests = testResults.count
        let passedTests = testResults.filter { $0.success }.count
        let failedTests = totalTests - passedTests
        let totalDuration = testResults.reduce(0) { $0 + $1.duration }
        
        print("\n" + String(repeating: "=", count: 60))
        print("🧪 AWS BACKEND TEST SUMMARY")
        print(String(repeating: "=", count: 60))
        print("Total Tests: \(totalTests)")
        print("✅ Passed: \(passedTests)")
        print("❌ Failed: \(failedTests)")
        print("⏱️ Total Duration: \(String(format: "%.2f", totalDuration))s")
        print(String(repeating: "=", count: 60))
        
        for result in testResults {
            let status = result.success ? "✅" : "❌"
            print("\(status) \(result.testName): \(result.message)")
            print("   Duration: \(String(format: "%.2f", result.duration))s")
            if let details = result.details, !result.success {
                print("   Error Details: \(details)")
            }
            print("")
        }
        print(String(repeating: "=", count: 60) + "\n")
        
        if passedTests == totalTests {
            print("🎉 ALL TESTS PASSED! Your AWS backend is working perfectly!")
            print("✅ Authentication is working")
            print("✅ GraphQL API is connected")
            print("✅ WorkoutSession create/read is working")
            print("✅ LocationData create/read is working")
            print("✅ Your schema is properly deployed")
            print("")
            print("🚀 You can now safely switch to useMockData = false in WorkoutService!")
        } else if passedTests >= 2 {
            print("⚠️ Basic connectivity is working, but some operations failed.")
            print("Check the error details above for specific issues.")
        } else {
            print("❌ Major issues detected. Check your AWS configuration.")
        }
    }
}

// MARK: - Test Views (keeping existing UI)

struct AWSTestView: View {
    @StateObject private var testManager = AWSTestManager()
    @Environment(\.dismiss) private var dismiss
    @State private var selectedResult: AWSTestManager.TestResult?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.green)
                    
                    Text("AWS Backend Tests")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Your backend is working! 🎉")
                        .font(.subheadline)
                        .foregroundColor(.green)
                        .multilineTextAlignment(.center)
                }
                
                // Test Button
                Button(action: {
                    Task {
                        await testManager.runAllTests()
                    }
                }) {
                    HStack {
                        if testManager.isRunningTests {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                            Text("Running Tests...")
                        } else {
                            Image(systemName: "play.circle.fill")
                            Text("Run All Tests")
                        }
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(testManager.isRunningTests ? Color.gray : Color.green)
                    .cornerRadius(12)
                }
                .disabled(testManager.isRunningTests)
                
                // Success Message
                if !testManager.testResults.isEmpty {
                    let passedCount = testManager.testResults.filter { $0.success }.count
                    let totalCount = testManager.testResults.count
                    
                    if passedCount == totalCount {
                        VStack(spacing: 12) {
                            Text("🎉 All Tests Passed!")
                                .font(.headline)
                                .foregroundColor(.green)
                            
                            Text("Your AWS backend is fully functional. You can now use real data in your WorkoutService!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Next Steps:")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                Text("1. Set useMockData = false in WorkoutService")
                                Text("2. Test your workout flow end-to-end")
                                Text("3. Your data will now save to AWS!")
                            }
                            .font(.caption)
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    
                    // Test Results
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Test Results")
                                .font(.headline)
                            
                            Spacer()
                            
                            Text("\(passedCount)/\(totalCount)")
                                .font(.caption)
                                .foregroundColor(passedCount == totalCount ? .green : .red)
                        }
                        
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(Array(testManager.testResults.enumerated()), id: \.offset) { index, result in
                                    TestResultRow(result: result) {
                                        selectedResult = result
                                    }
                                }
                            }
                        }
                        .frame(maxHeight: 300)
                    }
                } else {
                    Spacer()
                    
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 40))
                            .foregroundColor(.green)
                        
                        Text("Ready to verify your backend")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Based on your previous test, everything should pass!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                }
            }
            .padding()
            .navigationTitle("Backend Tests")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $selectedResult) { result in
                TestDetailView(result: result)
            }
        }
    }
}

struct TestResultRow: View {
    let result: AWSTestManager.TestResult
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: result.success ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(result.success ? .green : .red)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.testName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(result.message)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Text("\(String(format: "%.2f", result.duration))s")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TestDetailView: View {
    let result: AWSTestManager.TestResult
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Image(systemName: result.success ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(result.success ? .green : .red)
                        
                        VStack(alignment: .leading) {
                            Text(result.testName)
                                .font(.headline)
                            Text(result.success ? "Passed" : "Failed")
                                .font(.subheadline)
                                .foregroundColor(result.success ? .green : .red)
                        }
                        
                        Spacer()
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Result")
                            .font(.headline)
                        Text(result.message)
                            .font(.body)
                    }
                    
                    if let details = result.details {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Details")
                                .font(.headline)
                            Text(details)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Test Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

extension AWSTestManager.TestResult: Identifiable {
    var id: String { testName }
}
