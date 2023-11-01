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


  @StateObject var viewModel: TrainingSessionViewModel

  init(path: Binding<[TrainingSessionsNavigation]>, showToday: Binding<Bool>) {
    self._showToday = showToday
    self._path = path
    self._viewModel = StateObject(wrappedValue: TrainingSessionViewModel())
  }

  var body: some View {

    NavigationStack(path: $path) {

      ScrollView(.vertical, showsIndicators: false) {

        Button {
          if viewModel.day.timeIntervalSince1970 > Date.now.startOfDay.timeIntervalSince1970 {
            showingEditSheet.toggle()
          }
        } label: {
          if let session = viewModel.currentUserTrainingSesssion {
            TrainingSessionCell(trainingSession: session, shouldShowTime: viewModel.shouldShowTime)
          } else if !viewModel.isFirstFetch[viewModel.day.noon, default: true] && UserService.shared.currentUser != nil {
            RestDayCell(user: UserService.shared.currentUser!) //CRASH: force unwrap; FIX: added check above
          } else {
            ProgressView()
              .scaleEffect(1, anchor: .center)
              .progressViewStyle(CircularProgressViewStyle(tint: Color(.systemBlue)))
              .padding(.top, 15)
              .frame(width: 50)
          }
        }
        .padding(.top, 12)
        .padding(.bottom, 15)
        .sheet(isPresented: $showingEditSheet) {
          TrainingSessionSchedulerView(user: UserService.shared.currentUser!)
        }

        ForEach(viewModel.trainingSessions) { session in
          NavigationLink(value: TrainingSessionsNavigation.profile(session.user!)) {
            TrainingSessionCell(trainingSession: session, shouldShowTime: viewModel.shouldShowTime)
              .padding(.vertical, 12)
          }.disabled(session.user == nil)
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
      .navigationTitle(viewModel.relaiveDay())

      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
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
                viewModel.day = selectedDate
              }
              .datePickerStyle(.graphical)
              .presentationDetents([.medium])
              .presentationDragIndicator(.hidden)
          }
        }
      }
    }
    .gesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local)
      .onEnded { value in
        print(value.translation)
        switch(value.translation.width, value.translation.height) {
        case (...0, -30...30):
          viewModel.day = viewModel.day.addingTimeInterval(86400) //TODO: put this all in the viewModel
          selectedDate = selectedDate.addingTimeInterval(86400)   // too much dup
        case (0..., -30...30):
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
        selectedDate = Date()
        viewModel.day = selectedDate
      }
    }
    .onChange(of: showToday) { newValue in
      if showToday {
        showToday = false
        selectedDate = Date()         //TODO: reduce dup (see below)
        viewModel.day = selectedDate
      }
    }
    .onChange(of: showComments) { newValue in
      if !newValue {
        AppNavigation.shared.showCommentsTrainingSessionID = nil
      }
    }
    .onAppear{
      guard shouldSetDateOnAppear else {
        shouldSetDateOnAppear = true
        return
      }
      selectedDate = Date()
      viewModel.day = selectedDate
    }
    .environmentObject(viewModel)
    .sheet(isPresented: $showComments) {

      if trainingSession != nil {
        CommentsView(trainingSession: trainingSession!)
          .presentationDragIndicator(.visible)
      }
    }
    .onNotification { userInfo in
      shouldSetDateOnAppear = false

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

