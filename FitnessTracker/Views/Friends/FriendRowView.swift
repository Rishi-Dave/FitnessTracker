//
//  FriendRowView.swift
//  FitnessTracker
//
//  Created by Rishi Dave on 8/16/25.
//

import SwiftUI

struct FriendRowView: View {
    let friend: UserModel
    @State private var isFollowing = false
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: friend.profilePicture)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(friend.name)
                    .font(.headline)
                
                Text("Last workout: \(friend.lastWorkoutDate, style: .date)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(isFollowing ? "Following" : "Follow") {
                toggleFollow()
            }
            .buttonStyle(.bordered)
            .foregroundColor(isFollowing ? .secondary : .blue)
        }
    }
    
    private func toggleFollow() {
        isFollowing.toggle()
        // TODO: Implement follow/unfollow functionality with backend
    }
}
