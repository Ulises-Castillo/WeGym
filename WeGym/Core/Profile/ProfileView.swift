//
//  ProfileView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/12/23.
//

import SwiftUI

struct ProfileView: View {
  
  let user: User
  @Environment(\.dismiss) var dismiss
  
  private let gridItems: [GridItem] = [
    .init(.flexible(), spacing: 1),
    .init(.flexible(), spacing: 1),
    .init(.flexible(), spacing: 1),
  ]
  
  private let length = (UIScreen().bounds.width / 3) - 1 //FIXME: ?
  
  var body: some View {
    ScrollView {
      // header
      VStack(spacing: 10) {
        // pic and stats
        HStack {
          Spacer()
          Image(user.profileImageUrl ?? "")
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
        
        // action button //FIXME: should be follow button
        Button {
          
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
      
      // post grid view
      LazyVGrid(columns: gridItems, spacing: 1) {
        
        ForEach(0 ... 33, id: \.self) { _ in
          Image(user.profileImageUrl ?? "smoke")
            .resizable()
            .scaledToFill()
        }
      }
    }
    .navigationTitle(user.username) // yes, I like this better
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        Image(systemName: "chevron.left")
          .imageScale(.large)
          .onTapGesture {
            dismiss()
          }
        
      }
    }
  }
}

#Preview {
  ProfileView(user: User.MOCK_USERS[0])
}
