//
//  TrainingSessionCell.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/14/23.
//

import SwiftUI

struct TrainingSessionCell: View {
  @ObservedObject var cellViewModel: TrainingSessionCellViewModel
  @State var commentsViewMode = false
  @Environment(\.scenePhase) var scenePhase

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

  private var commentsCount: Int {
    return viewModel.commentsCountCache[trainingSession.id, default: 0]
  }

  let shouldShowTime: Bool
  @StateObject var userService = UserService.shared

  @EnvironmentObject var viewModel: TrainingSessionViewModel

  @State private var showComments = false

  var body: some View {
    VStack(alignment: .leading, spacing: 9) {

      HStack {
        if let user = trainingSession.user?.isCurrentUser ?? false ? userService.currentUser : trainingSession.user {
          // user profile image
          CircularProfileImageView(user: user, size: .xSmall)
          // username
          Text(user.fullName ?? user.username)
            .fontWeight(.bold)
            .font(.system(size: 14, weight: Font.Weight.bold, design: Font.Design.rounded))

          + Text(" ") + Text(trainingSession.caption ?? "")
            .fontWeight(.regular)
            .font(.system(size: 14, weight: Font.Weight.regular, design: Font.Design.rounded))
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
      .font(.system(size: 21, weight: .bold, design: Font.Design.rounded))

      HStack {
        if shouldShowTime {
          // TrainingSession time
          let date = trainingSession.date.dateValue()
          Text(date, format: Calendar.current.component(.minute, from: date) == 0 ? .dateTime.hour() : .dateTime.hour().minute())
            .font(.system(size: 14, weight: Font.Weight.semibold, design: Font.Design.rounded))
        }
        // TrainingSession location / gym
        if let location = trainingSession.location {
          Text(location)
            .foregroundColor(.secondary)
            .font(.system(size: 14, weight: Font.Weight.regular, design: Font.Design.rounded))
        }
      }

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
          showComments.toggle()
        } label: {
          Image(systemName: "bubble.right")
            .imageScale(.medium)
        }

        NavigationLink(value: TrainingSessionsNavigation.chat(trainingSession.user!)) {
          Image(systemName: "envelope")
            .imageScale(.medium)
        }.disabled(trainingSession.user == nil || trainingSession.user!.isCurrentUser)
        Spacer()
      }
      .padding(.leading, 8)
      .padding(.top, 4)
      .foregroundColor(.blue)

      // likes label
      if trainingSession.likes > 0 { //TODO: show list of ppl who liked
        Text("\(trainingSession.likes) like".appending(trainingSession.likes > 1 || trainingSession.likes == 0 ? "s" : ""))
          .font(.system(size: 14, weight: Font.Weight.semibold, design: Font.Design.rounded))
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.leading, 10)
      }
      // comments label
      if commentsCount > 0 { //TODO: show list of ppl who liked
        Button {
          commentsViewMode = true
          showComments.toggle()
        } label: {
          Text("View \(commentsCount) comment".appending(commentsCount > 1 || commentsCount == 0 ? "s" : ""))
            .font(.system(size: 14, weight: Font.Weight.regular, design: Font.Design.rounded))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 10)
            .padding(.top, -2)
            .foregroundColor(.secondary)
        }
      }
    }
    .padding(.leading, 21)
    .padding(.trailing, 9)
    .foregroundColor(.primary)
    .sheet(isPresented: $showComments) {
      CommentsView(trainingSession: trainingSession, viewMode: commentsViewMode)
        .presentationDragIndicator(.visible)
        .presentationDetents(commentsViewMode ? [PresentationDetent.fraction(0.75), .large] : [.large])
    }
    .onAppear {
      Task { try await viewModel.updateCommentsCountCache(trainingSessionId: trainingSession.id) }
    }
    .onChange(of: scenePhase) { newPhase in
      guard newPhase == .active else { return }
      Task { try await viewModel.updateCommentsCountCache(trainingSessionId: trainingSession.id) }
    }
    .onChange(of: showComments) { newValue in
      AppNavigation.shared.showCommentsTrainingSessionID = newValue ? trainingSession.id : nil
      if !showComments {
        commentsViewMode = false
        Task { try await viewModel.updateCommentsCountCache(trainingSessionId: trainingSession.id) }
      }
    }
    .onNotification { userInfo in
      guard let notificationType = userInfo["notificationType"] as? String else { return } //TODO: test this

      switch notificationType {
      case "new_training_session_comment":
        guard let uid = userInfo["trainingSessionUid"] as? String else { return }
        if trainingSession.id != uid {
          showComments = false
        }
      default:
        showComments = false
      }
    }
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
