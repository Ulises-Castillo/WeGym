//
//  TrainingSessionCell.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/14/23.
//

import SwiftUI

struct TrainingSessionCell: View {
  let trainingSession: TrainingSession
  let shouldShowTime: Bool

  @EnvironmentObject var viewModel: TrainingSessionViewModel

  var body: some View {
    VStack(alignment: .leading, spacing: 9) {
      
      HStack {
        if let user = trainingSession.user {
          // user profile image
          CircularProfileImageView(user: user, size: .xSmall)
          // username
          Text(user.fullName ?? user.username)
            .font(.subheadline)
            .fontWeight(.bold)
          
          + Text(" ") + Text(trainingSession.caption ?? "")
            .fontWeight(.semibold)
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        Spacer()
      }
      .frame(maxWidth: .infinity, alignment: .leading) // may not need this
      .multilineTextAlignment(.leading)
      .lineLimit(2)
      
      
      
      HStack {
        // body parts / workout type
        ForEach(viewModel.beautifyWorkoutFocuses(focuses: trainingSession.focus), id: \.self) { focus in
          Text(" \(focus)   ")
            .frame(height: 33)
            .background(Color(.systemBlue))
            .cornerRadius(6)
        }
      }
      .foregroundColor(.white)
      .fontWeight(.bold)
      .font(.title2)
      
      HStack {
        if shouldShowTime {
          // TrainingSession time
          Text(trainingSession.date.dateValue(), format: .dateTime.hour().minute())
            .fontWeight(.semibold)
        }
        // TrainingSession location / gym
        if let location = trainingSession.location {
          Text(location)
            .foregroundColor(.secondary)
        }
      }
      .font(.subheadline)
    }
    .padding(.leading, 21)
    .padding(.trailing, 9)
    .foregroundColor(.primary)
  }
}

#Preview {
  TrainingSessionCell(trainingSession: TrainingSession.MOCK_TRAINING_SESSIONS[0], shouldShowTime: true)
}
