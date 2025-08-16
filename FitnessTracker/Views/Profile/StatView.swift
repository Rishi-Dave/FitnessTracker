//
//  StatView.swift
//  FitnessTracker
//
//  Created by Rishi Dave on 8/16/25.
//

import SwiftUI

struct StatView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}
