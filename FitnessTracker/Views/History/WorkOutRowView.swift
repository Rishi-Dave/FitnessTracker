import SwiftUI

struct WorkoutRowView: View {
    let workout: WorkoutSessionModel
    
    var body: some View {
        HStack(spacing: 12) {
            // Workout Type Icon
            VStack {
                Image(systemName: "figure.run")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 40, height: 40)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())
                
                Spacer()
            }
            
            // Main Content
            VStack(alignment: .leading, spacing: 6) {
                // Date and Status
                HStack {
                    Text(workout.startTime, style: .date)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    if workout.isActive {
                        Text("ACTIVE")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.green)
                            .cornerRadius(4)
                    } else {
                        Text("COMPLETED")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Time of day
                Text(workout.startTime, style: .time)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Metrics Row
                HStack(spacing: 16) {
                    // Distance
                    HStack(spacing: 4) {
                        Image(systemName: "location")
                            .font(.caption)
                            .foregroundColor(.blue)
                        Text("\(String(format: "%.2f", workout.distance)) km")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    // Duration
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption)
                            .foregroundColor(.green)
                        Text(formatDuration(workout.duration))
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    Spacer()
                }
                
                // Pace (if available)
                if let averagePace = workout.averagePace {
                    HStack(spacing: 4) {
                        Image(systemName: "speedometer")
                            .font(.caption)
                            .foregroundColor(.orange)
                        Text("\(String(format: "%.1f", averagePace)) min/km")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else if workout.distance > 0 && workout.duration > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "speedometer")
                            .font(.caption)
                            .foregroundColor(.orange)
                        Text(calculateAveragePace(distance: workout.distance, duration: workout.duration))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
        }
        .padding(.vertical, 4)
    }
    
    private func formatDuration(_ duration: Int) -> String {
        let hours = duration / 3600
        let minutes = (duration % 3600) / 60
        let seconds = duration % 60
        
        if hours > 0 {
            return String(format: "%dh %dm", hours, minutes)
        } else if minutes > 0 {
            return String(format: "%dm %ds", minutes, seconds)
        } else {
            return String(format: "%ds", seconds)
        }
    }
    
    private func calculateAveragePace(distance: Double, duration: Int) -> String {
        guard distance > 0 && duration > 0 else { return "--:--" }
        let paceInSeconds = Double(duration) / distance / 60
        let minutes = Int(paceInSeconds)
        let seconds = Int((paceInSeconds - Double(minutes)) * 60)
        return String(format: "%d:%02d min/km", minutes, seconds)
    }
}

// MARK: - Enhanced Workout Summary Card

struct WorkoutSummaryCard: View {
    let workouts: [WorkoutSessionModel]
    
    private var totalDistance: Double {
        workouts.reduce(0) { $0 + $1.distance }
    }
    
    private var totalDuration: Int {
        workouts.reduce(0) { $0 + $1.duration }
    }
    
    private var averagePace: Double {
        let validWorkouts = workouts.filter { $0.distance > 0 && $0.duration > 0 }
        guard !validWorkouts.isEmpty else { return 0 }
        
        let totalPace = validWorkouts.reduce(0.0) { sum, workout in
            return sum + (Double(workout.duration) / workout.distance / 60.0)
        }
        return totalPace / Double(validWorkouts.count)
    }
    
    private var totalCalories: Int {
        // Rough estimate: 60 calories per km
        return Int(totalDistance * 60)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Summary")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("\(workouts.count) workouts")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                SummaryMetric(
                    title: "Total Distance",
                    value: String(format: "%.1f km", totalDistance),
                    icon: "location",
                    color: .blue
                )
                
                SummaryMetric(
                    title: "Total Time",
                    value: formatTotalDuration(totalDuration),
                    icon: "clock",
                    color: .green
                )
                
                SummaryMetric(
                    title: "Avg Pace",
                    value: averagePace > 0 ? String(format: "%.1f min/km", averagePace) : "--:--",
                    icon: "speedometer",
                    color: .orange
                )
                
                SummaryMetric(
                    title: "Est. Calories",
                    value: "\(totalCalories) cal",
                    icon: "flame",
                    color: .red
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func formatTotalDuration(_ duration: Int) -> String {
        let hours = duration / 3600
        let minutes = (duration % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct SummaryMetric: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(8)
    }
}

// MARK: - Workout Detail View

struct WorkoutDetailView: View {
    let workout: WorkoutSessionModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text(workout.startTime, style: .date)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(workout.startTime, style: .time)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if workout.isActive {
                        Text("ACTIVE WORKOUT")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.green)
                            .cornerRadius(8)
                    }
                }
                
                // Main Stats
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    DetailMetricCard(
                        title: "Distance",
                        value: String(format: "%.2f km", workout.distance),
                        icon: "location",
                        color: .blue
                    )
                    
                    DetailMetricCard(
                        title: "Duration",
                        value: formatDuration(workout.duration),
                        icon: "clock",
                        color: .green
                    )
                    
                    if let averagePace = workout.averagePace {
                        DetailMetricCard(
                            title: "Avg Pace",
                            value: String(format: "%.1f min/km", averagePace),
                            icon: "speedometer",
                            color: .orange
                        )
                    }
                    
                    if let elevation = workout.totalElevationGain {
                        DetailMetricCard(
                            title: "Elevation",
                            value: String(format: "%.0f m", elevation),
                            icon: "mountain.2",
                            color: .purple
                        )
                    }
                    
                    DetailMetricCard(
                        title: "Est. Calories",
                        value: "\(Int(workout.distance * 60)) cal",
                        icon: "flame",
                        color: .red
                    )
                }
                
                // Workout Timeline
                if let endTime = workout.endTime {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Workout Timeline")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 8) {
                            TimelineRow(
                                title: "Started",
                                time: workout.startTime,
                                icon: "play.circle",
                                color: .green
                            )
                            
                            TimelineRow(
                                title: "Finished",
                                time: endTime,
                                icon: "checkmark.circle",
                                color: .blue
                            )
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                
                Spacer(minLength: 40)
            }
            .padding()
        }
        .navigationTitle("Workout Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func formatDuration(_ duration: Int) -> String {
        let hours = duration / 3600
        let minutes = (duration % 3600) / 60
        let seconds = duration % 60
        
        if hours > 0 {
            return String(format: "%dh %dm %ds", hours, minutes, seconds)
        } else if minutes > 0 {
            return String(format: "%dm %ds", minutes, seconds)
        } else {
            return String(format: "%ds", seconds)
        }
    }
}

struct DetailMetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
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

struct TimelineRow: View {
    let title: String
    let time: Date
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(time, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}
