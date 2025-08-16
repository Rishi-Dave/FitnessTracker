import Foundation

struct UserModel: Identifiable, Codable {
    let id: String
    let name: String
    let email: String
    let profilePicture: String
    var totalWorkouts: Int           // Changed to var
    var totalDistance: Double        // Changed to var
    var friendsCount: Int            // Changed to var
    var lastWorkoutDate: Date        // Changed to var
    var friends: [String]            // Changed to var
    
    init(id: String = UUID().uuidString,
         name: String,
         email: String,
         profilePicture: String = "",
         totalWorkouts: Int = 0,
         totalDistance: Double = 0,
         friendsCount: Int = 0,
         lastWorkoutDate: Date = Date(),
         friends: [String] = []) {
        self.id = id
        self.name = name
        self.email = email
        self.profilePicture = profilePicture
        self.totalWorkouts = totalWorkouts
        self.totalDistance = totalDistance
        self.friendsCount = friendsCount
        self.lastWorkoutDate = lastWorkoutDate
        self.friends = friends
    }
}
