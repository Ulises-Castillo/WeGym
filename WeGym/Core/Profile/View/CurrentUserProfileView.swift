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
  
  var posts: [Post] {
    return Post.MOCK_POSTS.filter({ $0.user?.username == user.username })
  }
  
  var body: some View {
    NavigationStack {
      ScrollView {
        // header
        ProfileHeaderView(user: user)
          .fullScreenCover(isPresented: $showEditProfile) {
            EditProfileView(user: user)
          }
        
        PostGridView(posts: posts)
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
  CurrentUserProfileView(user: User.MOCK_USERS_2[0])
}
