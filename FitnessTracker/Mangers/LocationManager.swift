import CoreLocation
import SwiftUI
import UserNotifications

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var locations: [CLLocation] = []
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var totalDistance: Double = 0
    @Published var currentSpeed: Double = 0 // in m/s
    @Published var currentPace: Double = 0 // in min/km
    
    // Workout tracking properties
    private var isTrackingWorkout = false
    private var workoutStartTime: Date?
    private var lastLocationUpdate: Date?
    
    // Distance calculation
    private var previousLocation: CLLocation?
    private let minimumDistance: CLLocationDistance = 5.0 // meters
    private let maxSpeed: CLLocationDistance = 50.0 // m/s (unrealistic speed filter)
    
    // Permission request tracking
    private var hasRequestedPermission = false
    
    override init() {
        super.init()
        print("📍 LocationManager initializing...")
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5.0 // Update every 5 meters
        
        // Set initial authorization status
        authorizationStatus = locationManager.authorizationStatus
        
        print("📍 LocationManager initialized with status: \(authorizationStatus.description)")
        print("📍 Info.plist check - Looking for location usage descriptions...")
        
        // Check if Info.plist has required keys
        checkInfoPlistConfiguration()
    }
    
    // MARK: - Info.plist Validation
    
    private func checkInfoPlistConfiguration() {
        let bundle = Bundle.main
        
        // Check for required location usage descriptions
        let whenInUseKey = "NSLocationWhenInUseUsageDescription"
        let alwaysKey = "NSLocationAlwaysAndWhenInUseUsageDescription"
        
        let whenInUseDescription = bundle.object(forInfoDictionaryKey: whenInUseKey) as? String
        let alwaysDescription = bundle.object(forInfoDictionaryKey: alwaysKey) as? String
        
        print("📍 Info.plist Configuration Check:")
        print("   - \(whenInUseKey): \(whenInUseDescription != nil ? "✅ Present" : "❌ Missing")")
        print("   - \(alwaysKey): \(alwaysDescription != nil ? "✅ Present" : "❌ Missing")")
        
        if whenInUseDescription == nil {
            print("⚠️ WARNING: NSLocationWhenInUseUsageDescription is missing from Info.plist!")
            print("   Add this key with a description of why your app needs location access.")
        }
    }
    
    // MARK: - Permission Management
    
    func requestLocationPermission() {
        print("📍 requestLocationPermission() called")
        print("📍 Current status: \(authorizationStatus.description)")
        print("📍 Has requested before: \(hasRequestedPermission)")
        
        // Prevent multiple simultaneous requests
        guard !hasRequestedPermission else {
            print("📍 Permission request already in progress, skipping...")
            return
        }
        
        switch authorizationStatus {
        case .notDetermined:
            print("📍 Status not determined - requesting when in use authorization")
            hasRequestedPermission = true
            locationManager.requestWhenInUseAuthorization()
            
        case .denied:
            print("📍 Location access denied - need to direct to settings")
            openAppSettings()
            
        case .restricted:
            print("📍 Location access restricted")
            
        case .authorizedWhenInUse:
            print("📍 Already authorized when in use")
            
        case .authorizedAlways:
            print("📍 Already authorized always")
            
        @unknown default:
            print("📍 Unknown authorization status: \(authorizationStatus.rawValue)")
            hasRequestedPermission = true
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    private func openAppSettings() {
        DispatchQueue.main.async {
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl) { success in
                        print("📍 Opened settings: \(success)")
                    }
                }
            }
        }
    }
    
    var hasLocationPermission: Bool {
        let hasPermission = authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
        // print("📍 hasLocationPermission: \(hasPermission) (status: \(authorizationStatus.description))")
        return hasPermission
    }
    
    var locationPermissionStatus: String {
        switch authorizationStatus {
        case .notDetermined:
            return "Not requested"
        case .denied:
            return "Denied"
        case .restricted:
            return "Restricted"
        case .authorizedWhenInUse:
            return "Authorized (when in use)"
        case .authorizedAlways:
            return "Authorized (always)"
        @unknown default:
            return "Unknown (\(authorizationStatus.rawValue))"
        }
    }
    
    // MARK: - Workout Tracking
    
    func startWorkoutTracking() {
        print("🏃‍♂️ startWorkoutTracking() called")
        print("📍 Has permission: \(hasLocationPermission)")
        print("📍 Current status: \(authorizationStatus.description)")
        
        guard hasLocationPermission else {
            print("❌ Cannot start tracking: Location permission not granted")
            return
        }
        
        print("🏃‍♂️ Starting workout location tracking...")
        
        isTrackingWorkout = true
        workoutStartTime = Date()
        totalDistance = 0
        locations.removeAll()
        previousLocation = nil
        
        // Configure for workout tracking
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5.0
        
        locationManager.startUpdatingLocation()
        
        // Request notification permission for workout updates
        requestNotificationPermission()
        
        print("✅ Workout tracking started")
    }
    
    func stopWorkoutTracking() {
        print("⏹️ Stopping workout location tracking...")
        
        isTrackingWorkout = false
        workoutStartTime = nil
        lastLocationUpdate = nil
        
        locationManager.stopUpdatingLocation()
        print("✅ Workout tracking stopped")
    }
    
    func pauseWorkoutTracking() {
        print("⏸️ Pausing workout location tracking...")
        locationManager.stopUpdatingLocation()
    }
    
    func resumeWorkoutTracking() {
        guard isTrackingWorkout else {
            print("⚠️ Cannot resume: No workout tracking session active")
            return
        }
        
        guard hasLocationPermission else {
            print("❌ Cannot resume: Location permission not granted")
            return
        }
        
        print("▶️ Resuming workout location tracking...")
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - Distance Calculation
    
    private func updateDistance(from newLocation: CLLocation) {
        guard let previousLoc = previousLocation else {
            previousLocation = newLocation
            return
        }
        
        let distance = newLocation.distance(from: previousLoc)
        
        // Filter out unrealistic movements
        guard distance >= minimumDistance && distance <= maxSpeed * 5 else {
            print("🚫 Filtered location update: distance=\(distance)m")
            return
        }
        
        // Calculate time difference for speed validation
        let timeDiff = newLocation.timestamp.timeIntervalSince(previousLoc.timestamp)
        guard timeDiff > 0 else { return }
        
        let speed = distance / timeDiff // m/s
        
        // Filter unrealistic speeds
        guard speed <= maxSpeed else {
            print("🚫 Filtered unrealistic speed: \(speed) m/s")
            return
        }
        
        // Update total distance
        totalDistance += distance / 1000.0 // Convert to km
        
        // Update current speed and pace
        currentSpeed = speed
        if speed > 0 {
            currentPace = (1000 / 60) / speed // min/km
        }
        
        previousLocation = newLocation
        
        print("📍 Distance updated: +\(String(format: "%.0f", distance))m, Total: \(String(format: "%.2f", totalDistance))km")
    }
    
    // MARK: - Utility Methods
    
    func getCurrentWorkoutDuration() -> TimeInterval {
        guard let startTime = workoutStartTime else { return 0 }
        return Date().timeIntervalSince(startTime)
    }
    
    func getAverageSpeed() -> Double {
        guard let startTime = workoutStartTime, totalDistance > 0 else { return 0 }
        let duration = Date().timeIntervalSince(startTime) / 3600.0 // hours
        return totalDistance / duration // km/h
    }
    
    func getCurrentElevation() -> Double? {
        return currentLocation?.altitude
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let newStatus = manager.authorizationStatus
        print("📍 Location authorization changed to: \(newStatus.description) (raw: \(newStatus.rawValue))")
        
        DispatchQueue.main.async {
            self.authorizationStatus = newStatus
            // Reset the request flag when we get a response
            self.hasRequestedPermission = false
        }
        
        // Handle authorization changes
        switch newStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            print("✅ Location permission granted!")
            
        case .denied:
            print("❌ Location permission denied!")
            
        case .restricted:
            print("⚠️ Location permission restricted!")
            
        case .notDetermined:
            print("🤔 Location permission still not determined")
            
        @unknown default:
            print("🤔 Unknown location authorization status: \(newStatus.rawValue)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        
        print("📍 Location update received: \(newLocation.coordinate.latitude), \(newLocation.coordinate.longitude)")
        
        // Validate location accuracy
        guard newLocation.horizontalAccuracy <= 100 else {
            print("📍 Location accuracy too low: \(newLocation.horizontalAccuracy)m")
            return
        }
        
        // Filter out old/cached locations
        guard newLocation.timestamp.timeIntervalSinceNow > -5.0 else {
            print("📍 Filtered old location update")
            return
        }
        
        DispatchQueue.main.async {
            self.currentLocation = newLocation
            self.locations.append(newLocation)
            self.lastLocationUpdate = Date()
            
            // Only calculate distance during workout tracking
            if self.isTrackingWorkout {
                self.updateDistance(from: newLocation)
            }
        }
        
        // Notify workout service if tracking
        if isTrackingWorkout {
            NotificationCenter.default.post(
                name: .locationUpdate,
                object: newLocation
            )
        }
        
        print("📍 Location updated successfully: ±\(newLocation.horizontalAccuracy)m accuracy")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location manager error: \(error.localizedDescription)")
        
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                print("📍 Location access denied")
                DispatchQueue.main.async {
                    self.authorizationStatus = .denied
                }
            case .locationUnknown:
                print("📍 Location unknown - continuing to try")
            case .network:
                print("📍 Network error - check connectivity")
            default:
                print("📍 Other location error: \(clError.localizedDescription)")
            }
        }
    }
    
    // MARK: - Notifications
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("✅ Notification permission granted")
            } else if let error = error {
                print("❌ Notification permission error: \(error)")
            } else {
                print("❌ Notification permission denied")
            }
        }
    }
}

// MARK: - CLAuthorizationStatus Extension

extension CLAuthorizationStatus {
    var description: String {
        switch self {
        case .notDetermined:
            return "Not Determined"
        case .restricted:
            return "Restricted"
        case .denied:
            return "Denied"
        case .authorizedAlways:
            return "Authorized Always"
        case .authorizedWhenInUse:
            return "Authorized When In Use"
        @unknown default:
            return "Unknown (\(rawValue))"
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let locationUpdate = Notification.Name("locationUpdate")
    static let workoutTrackingStarted = Notification.Name("workoutTrackingStarted")
    static let workoutTrackingStopped = Notification.Name("workoutTrackingStopped")
}
