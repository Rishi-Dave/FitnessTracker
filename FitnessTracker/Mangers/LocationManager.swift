import CoreLocation
import SwiftUI
import UserNotifications

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var locations: [CLLocation] = []
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var totalDistance: Double = 0
    //private let workoutService = WorkoutService()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
    }
    
    func startTracking() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            return
        }
        
        locationManager.startUpdatingLocation()
        locations.removeAll()
    }
    
    func stopTracking() {
        locationManager.stopUpdatingLocation()
    }
    
    func setupGeofencing(center: CLLocationCoordinate2D, radius: CLLocationDistance) {
        let region = CLCircularRegion(center: center, radius: radius, identifier: "WorkoutArea")
        region.notifyOnEntry = true
        region.notifyOnExit = true
        locationManager.startMonitoring(for: region)
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.currentLocation = location
        self.locations.append(location)
        
        // Send location data to backend if workout is active
        /*
        if let sessionId = workoutService.currentWorkoutSession?.id {
            Task {
                try await workoutService.addLocationData(location, sessionId: sessionId)
            }
         
        }
         */
         
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        sendGeofenceNotification(title: "Welcome!", body: "You've entered \(region.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        sendGeofenceNotification(title: "Goodbye!", body: "You've left \(region.identifier)")
    }
    
    private func sendGeofenceNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}
