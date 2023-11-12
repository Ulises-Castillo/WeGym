//
//  TrainingSessionCell.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/14/23.
//

import SwiftUI

struct TrainingSessionCell: View {

  @Environment(\.scenePhase) var scenePhase
  let trainingSession: TrainingSession

  init(trainingSession: TrainingSession,
       showLikes: Bool = false,
       showComments: Bool = false,
       commentsViewMode: Bool = false,
       notificationCellMode: Bool = false) {
    self.trainingSession = trainingSession

    self._showLikes = State(initialValue: showLikes)
    self._showComments = State(initialValue: showComments)
    self._commentsViewMode = State(initialValue: commentsViewMode)
    self._notificationCellMode = State(initialValue: notificationCellMode)
  }

  //NOTE: this has to be separate from the main cache because the snapshot listener will always clear didLike
  // because didLike is specific to each user, setting didLike to true in the DB makes no sense.
  private var didLike: Bool {
    return viewModel.didLikeCache[trainingSession.id] ?? false
  }

  private var likesCount: Int { //TODO: test this
    return viewModel.trainingSessionsCache[viewModel.key(trainingSession.ownerUid, trainingSession.date.dateValue())]?.likes ?? 0
  }

  private var commentsCount: Int {
    return viewModel.commentsCountCache[trainingSession.id, default: 0]
  }

  @StateObject var userService = UserService.shared

  @EnvironmentObject var viewModel: TrainingSessionViewModel

  @State private var showLikes = false
  @State private var showComments = false
  @State var commentsViewMode = false
  @State var notificationCellMode = false

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
        // body parts / workout type        //TODO: consider horizontal scrollview beyond 3 focuses
        ForEach(beautifyWorkoutFocuses(focuses: Array(trainingSession.focus.prefix(3))), id: \.self) { focus in
          Text(" \((notificationCellMode ? " " : "") + focus)   ") //TODO: investigate actual root cause of issue
            .frame(width: (UIScreen.main.bounds.width/3) - 21, height: 32)
            .background(Color(.systemBlue))
            .cornerRadius(6)
        }
      }
      .foregroundColor(.white)
      .font(.system(size: 15, weight: .semibold, design: Font.Design.rounded))

      ForEach(trainingSession.personalRecords ?? [], id: \.self) { pr in
        PersonalRecordFlex(personalRecord: pr)
      }

      HStack {
        if trainingSession.shouldShowTime {
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

        if let user = trainingSession.user {
          NavigationLink(value: TrainingSessionsNavigation.chat(user)) { //TODO: set user on notification cell model
            Image(systemName: "envelope")
              .imageScale(.medium)
          }.disabled(trainingSession.user == nil || trainingSession.user!.isCurrentUser)
          Spacer()
        }
      }
      .padding(.leading, 8)
      .padding(.top, 4)
      .foregroundColor(.blue)

      // likes label
      if likesCount > 0 { //TODO: show list of ppl who liked
        Button {
          showLikes.toggle()
        } label: {
          Text("\(likesCount) like".appending(likesCount > 1 || likesCount == 0 ? "s" : ""))
            .font(.system(size: 14, weight: Font.Weight.semibold, design: Font.Design.rounded))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 10)
        }
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
    .sheet(isPresented: $showLikes) {
      VStack {
        Text("Likes")
          .font(.subheadline)
          .fontWeight(.semibold)
          .padding(.top, 24)
          .foregroundColor(.primary)

        Divider()
        UserListView(viewModel: SearchViewModel(config: .likes(trainingSession.id))) //TODO: should be able to follow ppl from here + go to their profile
          .presentationDragIndicator(.visible)
          .presentationDetents([PresentationDetent.fraction(0.60), .large])
          .padding(.top, 30)
      }
    }
    .onAppear {
      Task { await viewModel.updateCommentsCountCache(trainingSessionId: trainingSession.id) }
    }
    .onChange(of: scenePhase) { newPhase in
      guard newPhase == .active else { return }
      Task { await viewModel.updateCommentsCountCache(trainingSessionId: trainingSession.id) }
    }
    .onChange(of: showComments) { newValue in
      AppNavigation.shared.showCommentsTrainingSessionID = newValue ? trainingSession.id : nil
      if !showComments {
        commentsViewMode = false
        Task { await viewModel.updateCommentsCountCache(trainingSessionId: trainingSession.id) }
      }
    }
    .onNotification { userInfo in
      guard !notificationCellMode else { return } //prevent hide likes/comments bug from notification cell
      guard let notificationType = userInfo["notificationType"] as? String else { return } //TODO: test this
      showLikes = false

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
        await viewModel.unlike(trainingSession)
      } else {
        await viewModel.like(trainingSession)
      }
    }
  }
}

//#Preview {
//  TrainingSessionCell(trainingSession: TrainingSession.MOCK_TRAINING_SESSIONS[0], shouldShowTime: true)
//}
