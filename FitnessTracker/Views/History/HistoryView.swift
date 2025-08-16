// Views/History/HistoryView.swift
import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var workoutService: WorkoutService
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading workouts...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if workoutService.workoutHistory.isEmpty {
                    emptyStateView
                } else {
                    workoutList
                }
            }
            .navigationTitle("Workout History")
            .refreshable {
                await refreshWorkouts()
            }
            .onAppear {
                loadWorkoutHistory()
            }
        }
    }
    
    private var workoutList: some View {
        List {
            // Summary Section
            Section {
                WorkoutSummaryCard(workouts: workoutService.workoutHistory)
            }
            
            // Workouts List
            Section("Recent Workouts") {
                ForEach(workoutService.workoutHistory) { workout in
                    WorkoutRowView(workout: workout)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "figure.run.circle")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("No Workouts Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start your first workout to see it here!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Start Workout") {
                // Switch to workout tab
                if let tabView = findTabView() {
                    tabView.wrappedValue = 0
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func loadWorkoutHistory() {
        guard workoutService.workoutHistory.isEmpty else { return }
        
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                _ = try await workoutService.fetchWorkoutHistory()
                await MainActor.run {
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    private func refreshWorkouts() async {
        do {
            _ = try await workoutService.fetchWorkoutHistory()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func findTabView() -> Binding<Int>? {
        // This is a hack to find the tab binding - in real app you'd pass it down
        return nil
    }
}

// MARK: - Workout Summary Card

struct WorkoutSummaryCard: View {
    let workouts: [WorkoutSessionModel]
    
    private var totalDistance: Double {
        workouts.reduce(0) { $0 + $1.distance }
    }
    
    private var totalDuration: Int {
        workouts.reduce(0) { $0 + $1.duration }
    }
    
    private var averagePace: Double {
        let totalPace = workouts.compactMap { $0.averagePace }.reduce(0, +)
        return workouts.isEmpty ? 0 : totalPace / Double(workouts.count)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("This Month")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 20) {
                SummaryMetric(
                    title: "Distance",
                    value: String(format: "%.1f km", totalDistance),
                    icon: "location",
                    color: .blue
                )
                
                SummaryMetric(
                    title: "Time",
                    value: formatDuration(totalDuration),
                    icon: "clock",
                    color: .green
                )
                
                SummaryMetric(
                    title: "Avg Pace",
                    value: String(format: "%.1f", averagePace),
                    icon: "speedometer",
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
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
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
