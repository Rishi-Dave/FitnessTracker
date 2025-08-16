import Foundation

struct WorkoutSessionModel: Identifiable, Codable {
    let id: String
    let userId: String
    let startTime: Date
    var endTime: Date?               // Changed to var
    var distance: Double             // Changed to var
    var duration: Int                // Changed to var
    var averagePace: Double?         // Changed to var
    var totalElevationGain: Double?  // Changed to var
    var isActive: Bool               // Changed to var
    
    init(id: String = UUID().uuidString,
         userId: String,
         startTime: Date,
         endTime: Date? = nil,
         distance: Double = 0,
         duration: Int = 0,
         averagePace: Double? = nil,
         totalElevationGain: Double? = nil,
         isActive: Bool = true) {
        self.id = id
        self.userId = userId
        self.startTime = startTime
        self.endTime = endTime
        self.distance = distance
        self.duration = duration
        self.averagePace = averagePace
        self.totalElevationGain = totalElevationGain
        self.isActive = isActive
    }
}
