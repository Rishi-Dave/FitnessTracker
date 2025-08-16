//
//  LocationDataModel.swift
//  FitnessTracker
//
//  Created by Rishi Dave on 8/16/25.
//

import Foundation

struct LocationDataModel: Identifiable, Codable {
    let id: String
    let sessionId: String
    let latitude: Double
    let longitude: Double
    let altitude: Double?
    let timestamp: Date
    
    init(id: String = UUID().uuidString,
         sessionId: String,
         latitude: Double,
         longitude: Double,
         altitude: Double? = nil,
         timestamp: Date = Date()) {
        self.id = id
        self.sessionId = sessionId
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.timestamp = timestamp
    }
}
