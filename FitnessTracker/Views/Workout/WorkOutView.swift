// Views/Workout/WorkoutView.swift - Fixed Location Permission Handling
import SwiftUI
import MapKit
import CoreLocation

struct WorkoutView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var workoutService: WorkoutService
    @State private var isWorkoutActive = false
    @State private var workoutDuration: TimeInterval = 0
    @State private var timer: Timer?
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingWorkoutSummary = false
    @State private var lastWorkout: WorkoutSessionModel?
    @State private var showingStopAlert = false
    @State private var showingPermissionAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Location Permission Status (if needed)
                if !locationManager.hasLocationPermission {
                    locationPermissionBanner
                }
                
                // Map View
                MapView(isWorkoutActive: $isWorkoutActive, locationManager: locationManager)
                    .frame(height: 300)
                    .cornerRadius(12)
                    .overlay(
                        VStack {
                            if isWorkoutActive {
                                HStack {
                                    Text("🔴 LIVE")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.red)
                                    Spacer()
                                    if let accuracy = locationManager.currentLocation?.horizontalAccuracy {
                                        Text("GPS: \(accuracy, specifier: "%.0f")m")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.black.opacity(0.6))
                                            .cornerRadius(8)
                                    }
                                }
                                .padding()
                                Spacer()
                            }
                        }
                    )
                
                // Workout Metrics
                HStack(spacing: 15) {
                    MetricCard(
                        title: "Time",
                        value: formatTime(workoutDuration),
                        icon: "clock"
                    )
                    
                    MetricCard(
                        title: "Distance",
                        value: String(format: "%.2f km", locationManager.totalDistance),
                        icon: "location"
                    )
                    
                    MetricCard(
                        title: "Pace",
                        value: formatPace(locationManager.currentPace),
                        icon: "speedometer"
                    )
                }
                
                // Additional Stats (when workout is active)
                if isWorkoutActive || workoutService.currentWorkoutSession != nil {
                    HStack(spacing: 20) {
                        VStack {
                            Text("Elevation")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(locationManager.getCurrentElevation() ?? 0, specifier: "%.0f")m")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        
                        VStack {
                            Text("Speed")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(locationManager.currentSpeed * 3.6, specifier: "%.1f") km/h")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        
                        VStack {
                            Text("Points")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(locationManager.locations.count)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                // Workout Controls
                HStack(spacing: 20) {
                    if !isWorkoutActive && workoutService.currentWorkoutSession == nil {
                        // Start Workout Button
                        Button(action: startWorkout) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Start Workout")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(canStartWorkout ? Color.green : Color.gray)
                            .cornerRadius(25)
                        }
                        .disabled(!canStartWorkout)
                        
                    } else if isWorkoutActive {
                        // Pause Button
                        Button(action: pauseWorkout) {
                            HStack {
                                Image(systemName: "pause.fill")
                                Text("Pause")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 120, height: 50)
                            .background(Color.orange)
                            .cornerRadius(25)
                        }
                        
                        // Stop Button
                        Button(action: {
                            showingStopAlert = true
                        }) {
                            HStack {
                                Image(systemName: "stop.fill")
                                Text("Stop")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 120, height: 50)
                            .background(Color.red)
                            .cornerRadius(25)
                        }
                        
                    } else {
                        // Resume Button (workout paused)
                        Button(action: resumeWorkout) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Resume")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 120, height: 50)
                            .background(Color.green)
                            .cornerRadius(25)
                        }
                        
                        // End Button
                        Button(action: {
                            showingStopAlert = true
                        }) {
                            HStack {
                                Image(systemName: "checkmark")
                                Text("Finish")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 120, height: 50)
                            .background(Color.blue)
                            .cornerRadius(25)
                        }
                    }
                }
                
                // Status Messages
                statusMessagesView
                
                Spacer()
            }
            .padding()
            .navigationTitle("Workout")
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .alert("Stop Workout", isPresented: $showingStopAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Stop", role: .destructive) {
                    Task {
                        await endWorkout()
                    }
                }
            } message: {
                Text("Are you sure you want to stop this workout?")
            }
            .alert("Location Permission Required", isPresented: $showingPermissionAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Open Settings") {
                    openAppSettings()
                }
            } message: {
                Text("Location access is required to track workouts. Please enable location permissions in Settings > Privacy & Security > Location Services.")
            }
            .sheet(isPresented: $showingWorkoutSummary) {
                if let workout = lastWorkout {
                    WorkoutSummaryView(workout: workout) {
                        showingWorkoutSummary = false
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .locationUpdate)) { notification in
                if let location = notification.object as? CLLocation,
                   let sessionId = workoutService.currentWorkoutSession?.id {
                    Task {
                        try? await workoutService.addLocationData(location, sessionId: sessionId)
                    }
                }
            }
            .onAppear {
                // Check and request location permission on view appear
                checkLocationPermission()
            }
        }
    }
    
    // MARK: - UI Components
    
    private var locationPermissionBanner: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "location.slash")
                    .foregroundColor(.orange)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Location Access Required")
                        .font(.headline)
                        .foregroundColor(.orange)
                    
                    Text("Status: \(locationManager.locationPermissionStatus)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            Button(action: handleLocationPermissionRequest) {
                HStack {
                    Image(systemName: getPermissionIcon())
                    Text(permissionButtonText)
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(permissionButtonColor)
                .cornerRadius(10)
            }
            .disabled(locationManager.authorizationStatus == .restricted)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var statusMessagesView: some View {
        VStack(spacing: 8) {
            if workoutService.isTracking && isWorkoutActive {
                HStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    Text("Workout in progress...")
                }
                .font(.caption)
                .foregroundColor(.green)
                
            } else if workoutService.currentWorkoutSession != nil && !isWorkoutActive {
                HStack {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 8, height: 8)
                    Text("Workout paused")
                }
                .font(.caption)
                .foregroundColor(.orange)
                
            } else if !locationManager.hasLocationPermission {
                Text("Grant location permission to start tracking")
                    .font(.caption)
                    .foregroundColor(.orange)
                
            } else {
                Text("Ready to start tracking")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // GPS Status
            if let accuracy = locationManager.currentLocation?.horizontalAccuracy {
                let status = gpsStatus(accuracy: accuracy)
                Text("GPS: \(status.text) (\(accuracy, specifier: "%.0f")m)")
                    .font(.caption)
                    .foregroundColor(status.color)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var canStartWorkout: Bool {
        return locationManager.hasLocationPermission && !workoutService.isLoading
    }
    
    private var permissionButtonText: String {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            return "Grant Location Permission"
        case .denied:
            return "Open Settings"
        case .restricted:
            return "Location Restricted"
        case .authorizedWhenInUse, .authorizedAlways:
            return "✓ Permission Granted"
        @unknown default:
            return "Grant Permission"
        }
    }
    
    private var permissionButtonColor: Color {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            return .blue
        case .denied:
            return .orange
        case .restricted:
            return .gray
        case .authorizedWhenInUse, .authorizedAlways:
            return .green
        @unknown default:
            return .blue
        }
    }
    
    private func getPermissionIcon() -> String {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            return "location"
        case .denied:
            return "gear"
        case .restricted:
            return "exclamationmark.triangle"
        case .authorizedWhenInUse, .authorizedAlways:
            return "checkmark"
        @unknown default:
            return "location"
        }
    }
    
    private func gpsStatus(accuracy: Double) -> (text: String, color: Color) {
        switch accuracy {
        case ...5:
            return ("Excellent", .green)
        case 5...10:
            return ("Good", .blue)
        case 10...20:
            return ("Fair", .orange)
        default:
            return ("Poor", .red)
        }
    }
    
    // MARK: - Permission Handling
    
    private func checkLocationPermission() {
        
        // If permission is not determined, request it automatically
        if locationManager.authorizationStatus == .notDetermined {
            print("📍 Permission not determined, requesting automatically...")
            locationManager.requestLocationPermission()
        }
    }
    
    private func handleLocationPermissionRequest() {        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            print("📍 Requesting location permission...")
            locationManager.requestLocationPermission()
            
        case .denied:
            print("📍 Permission denied, showing settings alert...")
            showingPermissionAlert = true
            
        case .restricted:
            showError("Location services are restricted on this device. This may be due to parental controls or device management policies.")
            
        case .authorizedWhenInUse, .authorizedAlways:
            print("✅ Location permission already granted")
            showError("Location permission is already granted. You can start your workout!")
            
        @unknown default:
            print("📍 Unknown permission status, requesting...")
            locationManager.requestLocationPermission()
        }
    }
    
    private func openAppSettings() {
        print("📍 Opening app settings...")
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            showError("Unable to open settings")
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl) { success in
                print("📍 Settings opened: \(success)")
            }
        } else {
            showError("Unable to open settings")
        }
    }
    
    // MARK: - Workout Methods
    
    private func startWorkout() {
        print("🏃‍♂️ Attempting to start workout...")
        
        guard canStartWorkout else {
            if !locationManager.hasLocationPermission {
                showError("Location permission is required to track workouts.")
                handleLocationPermissionRequest()
            } else {
                showError("Cannot start workout at this time.")
            }
            return
        }
        
        print("✅ Starting workout...")
        isWorkoutActive = true
        workoutDuration = 0
        
        // Start location tracking
        locationManager.startWorkoutTracking()
        
        // Start workout session in service
        Task {
            do {
                try await workoutService.startWorkout()
                print("✅ Workout started successfully")
            } catch {
                await MainActor.run {
                    self.showError("Failed to start workout: \(error.localizedDescription)")
                    self.isWorkoutActive = false
                    self.locationManager.stopWorkoutTracking()
                }
            }
        }
        
        // Start duration timer
        startTimer()
    }
    
    private func pauseWorkout() {
        isWorkoutActive = false
        locationManager.pauseWorkoutTracking()
        workoutService.pauseWorkout()
        stopTimer()
        print("⏸️ Workout paused")
    }
    
    private func resumeWorkout() {
        guard workoutService.currentWorkoutSession != nil else {
            showError("No workout session to resume")
            return
        }
        
        isWorkoutActive = true
        locationManager.resumeWorkoutTracking()
        workoutService.resumeWorkout()
        startTimer()
        print("▶️ Workout resumed")
    }
    
    private func endWorkout() async {
        stopTimer()
        locationManager.stopWorkoutTracking()
        
        // Capture final metrics
        let finalDistance = locationManager.totalDistance
        let finalDuration = Int(workoutDuration)
        
        do {
            // Update final metrics
            try await workoutService.updateWorkoutMetrics(
                distance: finalDistance,
                duration: finalDuration
            )
            
            // End workout in service
            try await workoutService.endWorkout()
            
            await MainActor.run {
                // Store for summary
                self.lastWorkout = self.workoutService.workoutHistory.first
                
                // Reset UI
                self.isWorkoutActive = false
                self.workoutDuration = 0
                
                // Show workout summary
                self.showingWorkoutSummary = true
                
                print("✅ Workout ended successfully")
            }
            
        } catch {
            await MainActor.run {
                self.showError("Error ending workout: \(error.localizedDescription)")
                self.isWorkoutActive = false
                self.workoutDuration = 0
            }
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            DispatchQueue.main.async {
                self.workoutDuration += 1
                
                // Update metrics every 10 seconds
                if Int(self.workoutDuration) % 10 == 0 {
                    Task {
                        try? await self.workoutService.updateWorkoutMetrics(
                            distance: self.locationManager.totalDistance,
                            duration: Int(self.workoutDuration)
                        )
                    }
                }
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) % 3600 / 60
        let seconds = Int(time) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    private func formatPace(_ pace: Double) -> String {
        guard pace > 0 && pace < 60 else { return "--:--" }
        
        let minutes = Int(pace)
        let seconds = Int((pace - Double(minutes)) * 60)
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
        print("❌ Error: \(message)")
    }
}

// MARK: - Workout Summary View (unchanged)

struct WorkoutSummaryView: View {
    let workout: WorkoutSessionModel
    let onDismiss: () -> Void
    
    private var workoutDuration: String {
        let hours = workout.duration / 3600
        let minutes = (workout.duration % 3600) / 60
        let seconds = workout.duration % 60
        
        if hours > 0 {
            return String(format: "%dh %dm %ds", hours, minutes, seconds)
        } else {
            return String(format: "%dm %ds", minutes, seconds)
        }
    }
    
    private var averagePace: String {
        guard workout.distance > 0 else { return "--:--" }
        let paceInSeconds = Double(workout.duration) / workout.distance / 60
        let minutes = Int(paceInSeconds)
        let seconds = Int((paceInSeconds - Double(minutes)) * 60)
        return String(format: "%d:%02d /km", minutes, seconds)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("Workout Complete!")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Great job on your workout")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Stats Grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    StatCard(
                        title: "Distance",
                        value: String(format: "%.2f km", workout.distance),
                        icon: "location", color: .blue
                    )
                    StatCard(
                        title: "Duration",
                        value: workoutDuration,
                        icon: "clock", color: .blue
                    )
                    StatCard(
                        title: "Avg Pace",
                        value: averagePace,
                        icon: "speedometer", color: .blue
                    )
                    StatCard(
                        title: "Calories",
                        value: "~\(Int(workout.distance * 60))",
                        icon: "flame", color: .blue
                    )
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button("Share Workout") {
                        // TODO: Implement sharing
                        print("Share workout tapped")
                    }
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    
                    Button("View Details") {
                        // TODO: Navigate to workout details
                        print("View details tapped")
                    }
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
                }
            }
            .padding()
            .navigationTitle("Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDismiss()
                    }
                }
            }
        }
    }
}
/*
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
*/
