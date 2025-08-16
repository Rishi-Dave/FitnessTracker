//
//  NotificationService.swift
//  FitnessTracker
//
//  Created by Rishi Dave on 8/16/25.
//

import UserNotifications
import SwiftUI

class NotificationService: ObservableObject {
    
    init() {
        requestNotificationPermission()
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else {
                print("Notification permission denied")
            }
        }
    }
    
    func scheduleWorkoutReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Time to Workout!"
        content.body = "Don't forget your daily exercise routine."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "workout-reminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func sendGeofenceNotification(title: String, body: String) {
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
