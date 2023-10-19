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
  
  var body: some View {
    NavigationStack {
      ScrollView {
        // header
        ProfileHeaderView(user: user)
          .fullScreenCover(isPresented: $showEditProfile) {
            EditProfileView(user: user)
          }
        
        PostGridView(user: user)
      }
      .navigationTitle(user.username) // yes, I like this better
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            AuthService.shared.signOut()
          } label: {
            Image(systemName: "line.3.horizontal")
              .foregroundColor(.primary)
          }
        }
      }
    }
  }
  
}

#Preview {
  CurrentUserProfileView(user: User.MOCK_USERS[0])
}
