//
//  TrainingSessionsView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/14/23.
//

import SwiftUI
import Firebase

struct TrainingSessionsView: View {

  @Environment(\.scenePhase) var scenePhase
  @State private var selectedDate: Date = .now
  @State private var showingDateSheet = false
  @State private var showingEditSheet = false
  @State private var selectedUser: User?
  @State private var shouldSetDateOnAppear = true
  @Binding var path: [TrainingSessionsNavigation]
  @Binding var showToday: Bool
  @State private var showComments = false
  @State private var trainingSession: TrainingSession?
  @State private var defaultDayTimer: Timer?
  @State private var isAnimationForward = true

  @EnvironmentObject var viewModel: TrainingSessionViewModel

  init(path: Binding<[TrainingSessionsNavigation]>, showToday: Binding<Bool>) {
    self._showToday = showToday
    self._path = path
  }

  func animateDayChange(newDate: Date, duration: CGFloat) {
    guard !showingEditSheet else { return } //Fix: do not change day if user editing a workout
    isAnimationForward = newDate.timeIntervalSince1970 > viewModel.day.timeIntervalSince1970

    withAnimation(.interactiveSpring(duration: duration)) {
      selectedDate = newDate
      viewModel.day = selectedDate
    }
  }

  var body: some View {

    NavigationStack(path: $path) {

      ScrollView(.vertical, showsIndicators: false) {

        if !TrainingSessionService.hasBeenFetched(date: viewModel.day) {
          ProgressView()
            .scaleEffect(1, anchor: .center)
            .progressViewStyle(CircularProgressViewStyle(tint: Color(.systemBlue)))
            .padding(.top, 15)
            .frame(width: 50)
        }
        
        ReorderableForEach(items: viewModel.trainingSessions) { session in
          Button {
            defaultDayTimer?.invalidate()

            if let user = session.user {
              if user.isCurrentUser {
                if viewModel.day.timeIntervalSince1970 > Date.now.startOfDay.timeIntervalSince1970 {
                  showingEditSheet.toggle()
                }
              } else {
                path.append(.profile(user))
              }
            }
          } label: {
            if session.id == dummyId, let user = UserService.shared.currentUser {
              if TrainingSessionService.hasBeenFetched(date: viewModel.day) {
                RestDayCell(user: user)
              }
            } else {
              TrainingSessionCell(trainingSession: session)
            }
          }
          .padding(.vertical, 12)
          .sheet(isPresented: $showingEditSheet) {
            if let user = UserService.shared.currentUser {
              TrainingSessionSchedulerView(user: user) //TODO: test change
            }
          }
        } moveAction: { from, to in
          guard from != IndexSet(integer: 0), to != 0 else { return } // prevent Current User cell from being re-ordered
          viewModel.trainingSessions.move(fromOffsets: from, toOffset: to)
          viewModel.setUserFollowingOrder()
        }.transition(.asymmetric(insertion: .move(edge: isAnimationForward ? .trailing : .leading), removal: .move(edge: isAnimationForward ? .leading : .trailing)))
      }
      .navigationDestination(for: TrainingSessionsNavigation.self) { screen in
        switch screen {
        case .chat(let user):
          ChatView(user: user)
        case .profile(let user):
          ProfileView(user: user)
        }
      }
      .foregroundColor(.black)
      .navigationTitle(relativeDay(viewModel.day))

      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            defaultDayTimer?.invalidate()
            animateDayChange(newDate: viewModel.day.addingTimeInterval(86400), duration: 0.39)
          } label: {
            Image(systemName: "arrow.forward.square")
              .foregroundColor(Color(.systemBlue))
              .padding(.horizontal, 9)
          }
        }
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            defaultDayTimer?.invalidate()
            showingDateSheet.toggle()
          } label: {
            Image(systemName: "calendar")
              .foregroundColor(Color(.systemBlue))
          }
          .sheet(isPresented: $showingDateSheet) {
            DatePicker("", selection: $selectedDate, displayedComponents: .date)
              .datePickerStyle(.graphical)
              .presentationDetents([.medium])
              .presentationDragIndicator(.hidden)
          }
        }
      }
    }
    .gesture(DragGesture(minimumDistance: 1.5, coordinateSpace: .local)
      .onEnded { value in
        defaultDayTimer?.invalidate()
        switch(value.translation.width, value.translation.height) {
        case (...0, -60...60):
          animateDayChange(newDate: viewModel.day.addingTimeInterval(86400), duration: 0.39)
        case (0..., -60...60):
          animateDayChange(newDate: viewModel.day.addingTimeInterval(-86400), duration: 0.39)
        default:
          break
        }
      }
    )
    .onChange(of: scenePhase) { newPhase in
      guard shouldSetDateOnAppear else {
        shouldSetDateOnAppear = true
        return
      }
      if newPhase == .active {
        let (date, _) = viewModel.defaultDay()
        animateDayChange(newDate: date, duration: 0.39)
      }
    }
    .onChange(of: showToday) { newValue in
      if showToday {
        showToday = false
        let (date, _) = viewModel.defaultDay()
        animateDayChange(newDate: date, duration: 0.39)
      }
    }
    .onChange(of: showComments) { newValue in
      if !newValue {
        AppNavigation.shared.showCommentsTrainingSessionID = nil
      }
    }
    .onChange(of: selectedDate) { _ in
      if showingDateSheet {
        showingDateSheet = false
        animateDayChange(newDate: selectedDate, duration: 0.39)
      }
    }
    .onAppear{
      guard shouldSetDateOnAppear else {
        shouldSetDateOnAppear = true
        return
      }

      let (date, _) = viewModel.defaultDay()
      selectedDate = date
      viewModel.day = selectedDate

      // Timer intended only to deal with case where data has not been fetched yet (spinner)
      // waiting for data to check if we should show tomorrow view
      guard !TrainingSessionService.hasBeenFetched(date: Date()) else { return } //TODO: test Date() change (starting at 3Pm [after today's workout])

      //TODO: test all cases ensure user always in control – invalidate timer anytime user changes `viewModel.day()`

      defaultDayTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { timer in
        let (date, setTmr) = viewModel.defaultDay()

        animateDayChange(newDate: date, duration: 1.5)

        if setTmr || TrainingSessionService.hasBeenFetched(date: Date()) {
          timer.invalidate()
        }
      }
    }
    .onDisappear {
      viewModel.removeTrainingSessionListener()
    }
    .sheet(isPresented: $showComments) {

      if trainingSession != nil {
        CommentsView(trainingSession: trainingSession!)
          .presentationDragIndicator(.visible)
      }
    }
    .onNotification { userInfo in
      shouldSetDateOnAppear = false
      defaultDayTimer?.invalidate() //TODO: test notification behavior with new timer

      guard let notificationType = userInfo["notificationType"] as? String else { return }

      switch notificationType {
      case "new_training_session_comment":
        guard let uid = userInfo["trainingSessionUid"] as? String else { return }
        Task {
          trainingSession = try await TrainingSessionService.fetchUserTrainingSession(uid: uid) //TODO: cache training sessions to get instantly // This is FAILING sometimes WACK !
          AppNavigation.shared.showCommentsTrainingSessionID = trainingSession?.id
          animateDayChange(newDate: trainingSession?.date.dateValue() ?? Date(), duration: 0.39)
          showComments = true //TODO: should also scrollo to TrainingSession ID (scrollreader ?)
        }
      default:
        guard let dateString = userInfo["date"] as? String else { return }
        animateDayChange(newDate: dateString.parsedDate() ?? Date(), duration: 0.39)
      }

    }
  }
}

extension AnyTransition {
  static var backslide: AnyTransition {
    AnyTransition.asymmetric(
      insertion: .move(edge: .trailing),
      removal: .move(edge: .leading))}
}

#Preview {
  TrainingSessionsView(path: .constant([TrainingSessionsNavigation]()), showToday: .constant(false))
}

