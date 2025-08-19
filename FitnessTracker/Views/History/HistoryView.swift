// Views/History/HistoryView.swift - Updated with AWS Connection
import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var workoutService: WorkoutService
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading workouts...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if workoutService.workoutHistory.isEmpty && !isLoading {
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
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
                Button("Retry") {
                    loadWorkoutHistory()
                }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var workoutList: some View {
        List {
            // Summary Section
            Section {
                WorkoutSummaryCard(workouts: workoutService.workoutHistory)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }
            
            // Workouts List
            Section("Recent Workouts (\(workoutService.workoutHistory.count))") {
                ForEach(workoutService.workoutHistory) { workout in
                    NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                        WorkoutRowView(workout: workout)
                    }
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
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                let workouts = try await workoutService.fetchWorkoutHistory()
                print("📚 Loaded \(workouts.count) workouts in HistoryView")
                
                await MainActor.run {
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load workout history: \(error.localizedDescription)"
                    self.isLoading = false
                    self.showingError = true
                }
                print("❌ Error loading workout history: \(error)")
            }
        }
    }
    
    private func refreshWorkouts() async {
        do {
            let workouts = try await workoutService.fetchWorkoutHistory()
            print("🔄 Refreshed \(workouts.count) workouts")
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to refresh workouts: \(error.localizedDescription)"
                self.showingError = true
            }
            print("❌ Error refreshing workouts: \(error)")
        }
    }
    
    private func findTabView() -> Binding<Int>? {
        // This is a hack to find the tab binding - in real app you'd pass it down
        return nil
    }
}
