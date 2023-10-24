//
//  TrainingSessionCell.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/14/23.
//

import SwiftUI

struct TrainingSessionCell: View {
  @ObservedObject var cellViewModel: TrainingSessionCellViewModel

  init(trainingSession: TrainingSession, shouldShowTime: Bool) {
    self.shouldShowTime = shouldShowTime
    self.cellViewModel = TrainingSessionCellViewModel(trainingSession: trainingSession)
  }

  private var trainingSession: TrainingSession {
    return cellViewModel.trainingSession
  }

  private var didLike: Bool {
    return trainingSession.didLike ?? false
  }

  let shouldShowTime: Bool
  @StateObject var currentUser = CurrentUser.shared

  @EnvironmentObject var viewModel: TrainingSessionViewModel

  var body: some View {
    VStack(alignment: .leading, spacing: 9) {
      
      HStack {
        if let user = trainingSession.user?.isCurrentUser ?? false ? CurrentUser.shared.user : trainingSession.user {
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

      // action buttons
      HStack(spacing: 16) {
        Button {
          handleLikeTapped()
        } label: {
          Image(systemName: didLike ? "heart.fill" : "heart")
            .imageScale(.medium)
            .foregroundColor(didLike ? .red : .blue)
        }

        Button {
          print("Comment on post")
        } label: {
          Image(systemName: "bubble.right")
            .imageScale(.medium)
        }

        Button {
          print("Send Direct Message")
        } label: {
          Image(systemName: "envelope")
            .imageScale(.medium)
        }
        Spacer()
      }
      .padding(.leading, 8)
      .padding(.top, 4)
      .foregroundColor(.blue)

      // likes label
      Text("\(trainingSession.likes) likes")
        .font(.footnote)
        .fontWeight(.semibold)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 10)
        .padding(.top, 1)
    }
    .padding(.leading, 21)
    .padding(.trailing, 9)
    .foregroundColor(.primary)
  }
  
  private func handleLikeTapped() {
    Task {
      if didLike {
        try await cellViewModel.unlike()
      } else {
        try await cellViewModel.like()
      }
    }
  }
}

//#Preview {
//  TrainingSessionCell(trainingSession: TrainingSession.MOCK_TRAINING_SESSIONS[0], shouldShowTime: true)
//}
