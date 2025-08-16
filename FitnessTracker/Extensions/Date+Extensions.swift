//
//  Date+Extensions.swift
//  FitnessTracker
//
//  Created by Rishi Dave on 8/16/25.
//

import Foundation

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    func formatWorkoutDuration() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: self, to: Date()) ?? "0s"
    }
}
