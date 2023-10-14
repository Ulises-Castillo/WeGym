//
//  CurrentUserProfileView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/13/23.
//

import SwiftUI

struct CurrentUserProfileView: View {
  let user: User
  @State private var showEditProfile = false
  
  private let gridItems: [GridItem] = [
    .init(.flexible(), spacing: 1),
    .init(.flexible(), spacing: 1),
    .init(.flexible(), spacing: 1),
  ]
  
  var body: some View {
    NavigationStack {
      ScrollView {
        // header
        VStack(spacing: 10) {
          // pic and stats
          HStack {
            Spacer()
            Image("uly")
              .resizable()
              .scaledToFill()
              .frame(width: 80, height: 80)
              .clipShape(Circle())
            
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
            if let fullName = user.fullName {
              Text(fullName)
                .font(.footnote)
                .fontWeight(.semibold)
            }
            if let bio = user.bio {
              Text(bio)
                .font(.footnote)
            }
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.horizontal)
          
          // action button
          Button {
            showEditProfile.toggle()
          } label: {
            Text("Edit Profile")
              .font(.subheadline)
              .fontWeight(.semibold)
              .frame(width: 360, height: 32)
              .foregroundColor(.black)
              .overlay(RoundedRectangle(cornerRadius: 6).stroke(.gray, lineWidth: 1))
          }
          
          Divider()
        }
        .fullScreenCover(isPresented: $showEditProfile) {
          EditProfileView(user: user)
        }
        
        // post grid view
        LazyVGrid(columns: gridItems, spacing: 1) {
          
          ForEach(0 ... 33, id: \.self) { _ in
            Image("smoke")
              .resizable()
              .scaledToFill()
          }
        }
      }
      .navigationTitle(user.username) // yes, I like this better
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            AuthService.shared.signOut()
          } label: {
            Image(systemName: "line.3.horizontal")
              .foregroundColor(.black)
          }
        }
      }
    }
  }
  
}

#Preview {
  CurrentUserProfileView(user: User.MOCK_USERS[0])
}
