//
//  WorkOutRowView.swift
//  FitnessTracker
//
//  Created by Rishi Dave on 8/16/25.
//

import SwiftUI

struct WorkoutRowView: View {
    let workout: WorkoutSessionModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.startTime, style: .date)
                    .font(.headline)
                
                HStack {
                    Text("\(String(format: "%.2f", workout.distance)) km")
                    Text("•")
                    Text(formatDuration(workout.duration))
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("Avg Pace")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(calculateAveragePace(distance: workout.distance, duration: workout.duration))
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatDuration(_ duration: Int) -> String {
        let hours = duration / 3600
        let minutes = (duration % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private func calculateAveragePace(distance: Double, duration: Int) -> String {
        guard distance > 0 else { return "--:--" }
        let paceInSeconds = Double(duration) / distance / 60
        let minutes = Int(paceInSeconds)
        let seconds = Int((paceInSeconds - Double(minutes)) * 60)
        return String(format: "%d:%02d", minutes, seconds)
    }
}
