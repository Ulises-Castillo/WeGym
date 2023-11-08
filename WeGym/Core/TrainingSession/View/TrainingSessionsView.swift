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

  @EnvironmentObject var viewModel: TrainingSessionViewModel

  init(path: Binding<[TrainingSessionsNavigation]>, showToday: Binding<Bool>) {
    self._showToday = showToday
    self._path = path
//    self._viewModel = StateObject(wrappedValue: TrainingSessionViewModel())
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
        } else {
          Button {
              showingEditSheet.toggle()
          } label: {
            if let session = viewModel.currentUserTrainingSesssion {
              TrainingSessionCell(trainingSession: session)
            } else if let user = UserService.shared.currentUser {
              RestDayCell(user: user) //CRASH: force unwrap; FIX: added check above
            }
          }.disabled(viewModel.day.timeIntervalSince1970 < Date.now.startOfDay.timeIntervalSince1970)
          .padding(.top, 12)
          .padding(.bottom, 15)
          .sheet(isPresented: $showingEditSheet) {
            TrainingSessionSchedulerView(user: UserService.shared.currentUser!)
          }
        }

        ReorderableForEach(items: viewModel.trainingSessions) { session in

          NavigationLink(value: TrainingSessionsNavigation.profile(session.user!)) {
            TrainingSessionCell(trainingSession: session)
              .padding(.vertical, 12)
          }.disabled(session.user == nil)

        } moveAction: { from, to in
          viewModel.trainingSessions.move(fromOffsets: from, toOffset: to)
          viewModel.setUserFollowingOrder()
        }
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
            viewModel.day = viewModel.day.addingTimeInterval(86400)
            selectedDate = selectedDate.addingTimeInterval(86400)
          } label: {
            Image(systemName: "arrow.forward.square")
              .foregroundColor(Color(.systemBlue))
              .padding(.horizontal, 9)
          }
        }
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            showingDateSheet.toggle()
          } label: {
            Image(systemName: "calendar")
              .foregroundColor(Color(.systemBlue))
          }
          .sheet(isPresented: $showingDateSheet) {
            DatePicker("", selection: $selectedDate, displayedComponents: .date)
              .onChange(of: selectedDate) { _ in
                showingDateSheet.toggle()
                defaultDayTimer?.invalidate() //TODO: test behavior with new timer
                viewModel.day = selectedDate
              }
              .datePickerStyle(.graphical)
              .presentationDetents([.medium])
              .presentationDragIndicator(.hidden)
          }
        }
      }
    }
    .gesture(DragGesture(minimumDistance: 1.5, coordinateSpace: .local)
      .onEnded { value in
        print(value.translation)
        switch(value.translation.width, value.translation.height) {
        case (...0, -60...60):
          defaultDayTimer?.invalidate()
          viewModel.day = viewModel.day.addingTimeInterval(86400) //TODO: put this all in the viewModel
          selectedDate = selectedDate.addingTimeInterval(86400)   // too much dup
        case (0..., -60...60):
          defaultDayTimer?.invalidate()
          viewModel.day = viewModel.day.addingTimeInterval(-86400) //TODO: move to constant file
          selectedDate = selectedDate.addingTimeInterval(-86400)
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
        selectedDate = date
        viewModel.day = selectedDate
      }
    }
    .onChange(of: showToday) { newValue in
      if showToday {
        showToday = false
        let (date, _) = viewModel.defaultDay()
        selectedDate = date
        viewModel.day = selectedDate
      }
    }
    .onChange(of: showComments) { newValue in
      if !newValue {
        AppNavigation.shared.showCommentsTrainingSessionID = nil
      }
    }
    .onChange(of: showingDateSheet) { _ in
      defaultDayTimer?.invalidate()
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
      defaultDayTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
//        print("***** Timer fired !!")
        let (date, setTmr) = viewModel.defaultDay()

        withAnimation(.default) {
          selectedDate = date
          viewModel.day = selectedDate
        }

        if setTmr || TrainingSessionService.hasBeenFetched(date: Date()) {
          timer.invalidate()
        }
      }
    }
    .onDisappear {
      viewModel.removeTrainingSessionListener()
    }
//    .environmentObject(viewModel)
    .sheet(isPresented: $showComments) {

      if trainingSession != nil {
        CommentsView(trainingSession: trainingSession!)
          .presentationDragIndicator(.visible)
      }
    }
    .task { //TODO: cache traing sessions also
      await UserService.shared.updateCache() //TODO: use userservice cache across the app
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
          selectedDate = trainingSession?.date.dateValue() ?? Date() //training session date retrieved manually
          viewModel.day = selectedDate
          showComments = true //TODO: should also scrollo to TrainingSession ID (scrollreader ?)
        }
      default:
        guard let dateString = userInfo["date"] as? String else { return }
        selectedDate = dateString.parsedDate() ?? Date() //training session date passed from like notification
        viewModel.day = selectedDate
      }

    }
  }
}

#Preview {
  TrainingSessionsView(path: .constant([TrainingSessionsNavigation]()), showToday: .constant(false))
}

