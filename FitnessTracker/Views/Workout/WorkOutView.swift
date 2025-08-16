import SwiftUI
import MapKit

struct WorkoutView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var workoutService: WorkoutService
    @State private var isWorkoutActive = false
    @State private var workoutDuration: TimeInterval = 0
    @State private var distance: Double = 0
    @State private var startTime: Date?
    @State private var timer: Timer?
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Map View
                MapView(isWorkoutActive: $isWorkoutActive,
                       locationManager: locationManager)
                    .frame(height: 300)
                    .cornerRadius(12)
                
                // Workout Metrics
                HStack(spacing: 20) {
                    MetricCard(title: "Time",
                              value: formatTime(workoutDuration),
                              icon: "clock")
                    
                    MetricCard(title: "Distance",
                              value: String(format: "%.2f km", distance),
                              icon: "location")
                    
                    MetricCard(title: "Pace",
                              value: calculatePace(),
                              icon: "speedometer")
                }
                
                // Workout Controls
                HStack(spacing: 30) {
                    if !isWorkoutActive {
                        Button(action: startWorkout) {
                            Text("Start Workout")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 150, height: 50)
                                .background(Color.green)
                                .cornerRadius(25)
                        }
                        .disabled(workoutService.isTracking)
                    } else {
                        Button(action: pauseWorkout) {
                            Text("Pause")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 80, height: 50)
                                .background(Color.orange)
                                .cornerRadius(25)
                        }
                        
                        Button(action: endWorkout) {
                            Text("End")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 80, height: 50)
                                .background(Color.red)
                                .cornerRadius(25)
                        }
                    }
                }
                
                // Current Status
                if workoutService.isTracking {
                    Text("Workout in progress...")
                        .font(.caption)
                        .foregroundColor(.green)
                } else if workoutService.currentWorkoutSession != nil {
                    Text("Workout paused")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Workout")
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
        .onChange(of: locationManager.totalDistance) { oldValue, newValue in
            // Update distance when location manager updates
            distance = newValue
        }
    }
    
    // MARK: - Private Methods
    
    private func startWorkout() {
        guard locationManager.authorizationStatus == .authorizedWhenInUse ||
              locationManager.authorizationStatus == .authorizedAlways else {
            showError("Location permission required to track workouts")
            return
        }
        
        isWorkoutActive = true
        startTime = Date()
        workoutDuration = 0
        distance = 0
        
        // Start location tracking
        locationManager.startTracking()
        
        // Start workout session in service
        Task {
            do {
                try await workoutService.startWorkout()
            } catch {
                await MainActor.run {
                    self.showError("Failed to start workout: \(error.localizedDescription)")
                }
            }
        }
        
        // Start timer - capture values to avoid environment object issues
        let capturedLocationManager = locationManager
        let capturedWorkoutService = workoutService
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            DispatchQueue.main.async {
                self.workoutDuration += 1
                self.distance = capturedLocationManager.totalDistance
                
                // Update service every 10 seconds
                if Int(self.workoutDuration) % 10 == 0 {
                    Task {
                        try? await capturedWorkoutService.updateWorkoutMetrics(
                            distance: self.distance,
                            duration: Int(self.workoutDuration)
                        )
                    }
                }
            }
        }
    }
    
    private func pauseWorkout() {
        isWorkoutActive = false
        timer?.invalidate()
        timer = nil
        locationManager.stopTracking()
        workoutService.pauseWorkout()
    }
    
    private func endWorkout() {
        isWorkoutActive = false
        timer?.invalidate()
        timer = nil
        locationManager.stopTracking()
        
        // End workout in service
        Task {
            do {
                try await workoutService.endWorkout()
                await MainActor.run {
                    // Reset UI
                    self.workoutDuration = 0
                    self.distance = 0
                    self.startTime = nil
                }
                print("Workout ended successfully")
            } catch {
                await MainActor.run {
                    self.showError("Error ending workout: \(error.localizedDescription)")
                }
            }
        }
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
    
    private func calculatePace() -> String {
        guard distance > 0 && workoutDuration > 0 else { return "--:--" }
        
        let paceInSeconds = (workoutDuration / 60) / distance
        let minutes = Int(paceInSeconds)
        let seconds = Int((paceInSeconds - Double(minutes)) * 60)
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }
}
