import Foundation

struct ActiveWorkoutModel: Identifiable, Codable {
    let id: String
    let userId: String
    let userName: String
    let userProfilePic: String
    var currentDistance: Double      // Changed to var
    var currentDuration: TimeInterval // Changed to var
    let startTime: Date
    var lastLocationUpdate: Date     // Changed to var
    
    init(id: String = UUID().uuidString,
         userId: String,
         userName: String,
         userProfilePic: String = "",
         currentDistance: Double = 0,
         currentDuration: TimeInterval = 0,
         startTime: Date = Date(),
         lastLocationUpdate: Date = Date()) {
        self.id = id
        self.userId = userId
        self.userName = userName
        self.userProfilePic = userProfilePic
        self.currentDistance = currentDistance
        self.currentDuration = currentDuration
        self.startTime = startTime
        self.lastLocationUpdate = lastLocationUpdate
    }
}
