//
//  ProfileHeaderView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/14/23.
//

import SwiftUI

struct ProfileHeaderView: View {
  let user: User
  @State private var showEditProfile = false
  
  var body: some View {
    // header
    VStack(spacing: 10) {
      // pic and stats
      HStack {
        Spacer()
        CircularProfileImageView(user: user, size: .large)
        
        Spacer()
        
        HStack(spacing: 8) {
          UserStatView(value: 315, title: "Squat")
          UserStatView(value: 245, title: "Bench")
          UserStatView(value: 365, title: "Deadlift")
        }
        
      }
      .padding(.horizontal)
      .padding(.bottom, 4)
      
      // name and bio
      VStack(alignment: .leading, spacing: 4) {
        
        Text(user.name)
          .font(.footnote)
          .fontWeight(.semibold)
        if let bio = user.bio {
          Text(bio)
            .font(.footnote)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.horizontal)
      
      // action button //FIXME: should be follow button
      Button {
        if user.isCurrentUser {
          showEditProfile.toggle()
        } else {
          print("Follow user")
        }
      } label: {
        Text(user.isCurrentUser ? "Edit Profile" : "Follow")
          .font(.subheadline)
          .fontWeight(.semibold)
          .frame(width: 360, height: 32)
          .background(user.isCurrentUser ? .white : Color(.systemBlue))
          .foregroundColor(user.isCurrentUser ? .black : .white)
          .cornerRadius(6)
          .overlay(RoundedRectangle(cornerRadius: 6).stroke(user.isCurrentUser ? .gray : .clear, lineWidth: 1))
      }
      
      Divider()
    }
    .fullScreenCover(isPresented: $showEditProfile) {
      EditProfileView(user: user)
    }
  }
}

#Preview {
  ProfileHeaderView(user: User.MOCK_USERS_2[0])
}
