//
//  TrainingSessionCell.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/14/23.
//

import SwiftUI
import Kingfisher

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

  private var imageUrl: String? {
    guard !viewModel.isImagesCollapsed else { return nil }
    return trainingSession.imageUrl
    //    return UserService.shared.currentUser?.profileImageUrl // TEST
  }

  private var focusColor: Color {
    let now = Date.now
    let numDays = Calendar.current.numberOfDaysBetween(now, and: viewModel.day)
    let isFuture = viewModel.day.noon.timeIntervalSince1970 >= now.noon.timeIntervalSince1970

    let blue = UIColor.systemBlue
    var adj = CGFloat(numDays) * 5  // Adjust by 5% per day
    if adj > 20 { adj = 20 }        // floor: 20%

    return Color(isFuture ? (blue.darker(by: adj) ?? blue) : (blue.lighter(by: adj) ?? blue))
  }

  @StateObject var userService = UserService.shared

  @EnvironmentObject var viewModel: TrainingSessionViewModel

  @State private var showLikes = false
  @State private var showComments = false
  @State private var showEditPrSheet = false
  @State var commentsViewMode = false
  @State var notificationCellMode = false
  @State var selectedPR: PersonalRecord?
  @State var image = Image(systemName: "person.circle.fill")

  var body: some View {
    VStack(alignment: .leading, spacing: 9) {

      ZStack {
        if let imageURL = imageUrl  {
          KFImage(URL(string: imageURL))
            .placeholder {
              Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: UIScreen.main.bounds.width - 16, height: UIScreen.main.bounds.width - 16)
              //                .clipShape(Circle())
                .clipped()
                .foregroundColor(Color(.systemGray4))
                .opacity(0.3)
            }
            .onSuccess { result in
              image = Image(uiImage: result.image)
            }
            .resizable()
            .scaledToFill()
            .frame(width: UIScreen.main.bounds.width - 16, height: UIScreen.main.bounds.width - 16)
          //            .clipShape(Square())
            .clipped()
            .onTapGesture {
              AppNavigation.shared.image = image
              AppNavigation.shared.showImageViewer.toggle()
            }
        }

        VStack(alignment: .leading, spacing: 9) {
          HStack {
            if let user = trainingSession.user?.isCurrentUser ?? false ? userService.currentUser : trainingSession.user {
              // user profile image
              CircularProfileImageView(user: user, size: .xSmall)
                .padding(.leading, imageUrl == nil ? 0 : 6)
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
          .frame(height: 48) //TODO: make dynamic based on image or not if necessary
          .multilineTextAlignment(.leading)
          .lineLimit(2)
          .background(.black.opacity(0.3))

          if imageUrl != nil {
            Spacer()
          }

          VStack(alignment: .leading, spacing: 9) {
            HStack {
              // body parts / workout type        //TODO: consider horizontal scrollview beyond 3 focuses
              ForEach(beautifyWorkoutFocuses(focuses: Array(trainingSession.focus.prefix(3))), id: \.self) { focus in
                Text(" \((notificationCellMode ? " " : "") + focus)   ") //TODO: investigate actual root cause of issue
                  .frame(width: (UIScreen.main.bounds.width/3) - 21, height: 32)
                  .background(focusColor)
                  .cornerRadius(6)
              }
            }
            .foregroundColor(.white)
            .font(.system(size: 15, weight: .semibold, design: Font.Design.rounded))

            ForEach(trainingSession.personalRecords ?? [], id: \.self) { pr in
              Button {
                selectedPR = pr
                showEditPrSheet.toggle()
              } label: {
                PersonalRecordFlex(personalRecord: pr)
              }.disabled(trainingSession.user?.isCurrentUser == false)
            }
          }
          .padding(imageUrl == nil ? 0 : 6)
        }

      }

      HStack {
        VStack(alignment: .leading, spacing: 9) {
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

            if let user = trainingSession.user, !user.isCurrentUser {
              NavigationLink(value: WGNavigation.chat(user)) { //TODO: set user on notification cell model
                Image(systemName: "envelope")
                  .imageScale(.medium)
              }.disabled(trainingSession.user == nil || trainingSession.user!.isCurrentUser)
              Spacer()
            }

            if let user = trainingSession.user, user.isCurrentUser {
              Button {
                showEditPrSheet.toggle()
              } label: {                //TODO: move to computed property "isFutureTrainingSession"
                //            let imageName = trainingSession.date.dateValue().timeIntervalSince1970 > Date.now.timeIntervalSince1970 ? "scope" : "trophy" // future feature: set goals for future sessions
                Image(systemName: "trophy")
                  .imageScale(.medium)
              }
            }
          }
          .padding(.leading, 8)
          .padding(.top, 4)
          .foregroundColor(.blue)


        }
        Spacer()

        if let imageURL = trainingSession.imageUrl, viewModel.isImagesCollapsed { //TODO: uncomment
          KFImage(URL(string: imageURL))
            .placeholder {
              Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 45, height: 45)
                .clipped()
                .foregroundColor(Color(.systemGray4))
                .opacity(0.3)
            }
            .onSuccess { result in
              image = Image(uiImage: result.image)
            }
            .resizable()
            .scaledToFill()
            .frame(width: 45, height: 45)
            .clipped()
            .cornerRadius(6)
            .padding(.trailing, 33)
            .padding(.top, 9)
            .onTapGesture {
              AppNavigation.shared.image = image
              AppNavigation.shared.showImageViewer.toggle()
            }
        }
      }

      // likes label
      if likesCount > 0 { //TODO: show list of ppl who liked
        Button {
          showLikes.toggle()
        } label: {
          Text("\(likesCount) like".appending(likesCount > 1 || likesCount == 0 ? "s" : ""))
            .font(.system(size: 14, weight: Font.Weight.semibold, design: Font.Design.rounded))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 10)
            .padding(.top, -1)
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
    .sheet(isPresented: $showEditPrSheet) {
      EditPersonalRecordView(selectedPR, date: viewModel.day)
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
      viewModel.isShowingComment_TrainingSessionCell = newValue
      AppNavigation.shared.showCommentsTrainingSessionID = newValue ? trainingSession.id : nil
      if !showComments {
        commentsViewMode = false
        Task { await viewModel.updateCommentsCountCache(trainingSessionId: trainingSession.id) }
      }
    }
    .onChange(of: showLikes) { newValue in
      viewModel.isShowingLikes_TrainingSessionCell = newValue
    }
    .onChange(of: showEditPrSheet) { newValue in
      if !newValue {
        selectedPR = nil
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
