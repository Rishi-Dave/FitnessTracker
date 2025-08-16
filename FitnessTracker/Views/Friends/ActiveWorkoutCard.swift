//
//  ActiveWorkoutCard.swift
//  FitnessTracker
//
//  Created by Rishi Dave on 8/16/25.
//

import SwiftUI

struct ActiveWorkoutCard: View {
    let workout: ActiveWorkoutModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                AsyncImage(url: URL(string: workout.userProfilePic)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                
                VStack(alignment: .leading) {
                    Text(workout.userName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text("Running")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(String(format: "%.2f", workout.currentDistance)) km")
                    .font(.headline)
                
                Text(formatTime(workout.currentDuration))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .frame(width: 150)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
