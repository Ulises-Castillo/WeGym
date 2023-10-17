//
//  RestDayCell.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/17/23.
//

import SwiftUI

struct RestDayCell: View {
  
  let user: User
  
  var body: some View {
    
    VStack(spacing: 9) {
      HStack {
        // user profile image
        CircularProfileImageView(user: user, size: .xSmall)
        // username
        Text(user.fullName!) //FIXME: unwrap
          .font(.subheadline)
          .fontWeight(.semibold)
        
        //TODO: in the future, should be able to add caption for rest days "Travel Day- going to Maui"
        Spacer()
      }
      .padding(.leading, 21)
      
      Text("Rest Day 😞")
        .font(.largeTitle)
      //          .fontWeight(.)
      HStack {
        Image(systemName: "plus")
        Text("Add Training Session")
          .font(.subheadline)
          .fontWeight(.medium)
      }
    }
  }
}

#Preview {
  RestDayCell(user: User.MOCK_USERS_2[0])
}
