//
//  RestDayCell.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/17/23.
//

import SwiftUI

struct RestDayCell: View {
  
  let user: User
  @EnvironmentObject var viewModel: TrainingSessionViewModel
  
  var body: some View {
    
    VStack(spacing: 9) {
      HStack {
        // user profile image
        CircularProfileImageView(user: user, size: .xSmall)
        // username
        Text(user.fullName ?? user.username)
          .font(.subheadline)
          .fontWeight(.semibold)
        
        //TODO: in the future, should be able to add caption for rest days "Travel Day- going to Maui"
        Spacer()
      }
      .padding(.leading, 21)
      
      Text("Rest Day 😞")
        .font(.largeTitle)
      if viewModel.day.timeIntervalSince1970 > Date.now.startOfDay.timeIntervalSince1970 {
        HStack {
          Image(systemName: "plus")
          Text("Add Workout")
            .font(.subheadline)
            .fontWeight(.medium)
            .padding(.trailing)
            
        }
        .foregroundColor(Color(.systemBlue))
      }
    }
    .foregroundColor(.primary)
  }
}

#Preview {
  RestDayCell(user: User.MOCK_USERS_2[0])
}
