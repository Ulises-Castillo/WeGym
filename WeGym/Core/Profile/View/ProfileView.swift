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
  
  
  var body: some View {
    ScrollView {
      ProfileHeaderView(user: user)
      
      PostGridView(user: user)
    }
    .navigationTitle("WeGym") // yes, I like this better
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
  ProfileView(user: User.MOCK_USERS_2[0])
}
