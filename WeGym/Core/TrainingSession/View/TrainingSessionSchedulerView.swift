//
//  TrainingSessionSchedulerView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/15/23.
//

import SwiftUI
import Combine
import Firebase
import SlideButton

struct TrainingSessionSchedulerView: View {
  @State var workoutTime = Date()
  @State var workoutCaption = ""
  @State var workoutIsRecurring = false
  @State var workoutBroLimit = ""
  @State private var showingSearchSheet = false

  @Environment(\.dismiss) var dismiss
  @EnvironmentObject var viewModel: TrainingSessionViewModel
  @StateObject var schedulerViewModel = TrainingSessionSchedulerViewModel()

  let user: User
  let captionLengthLimit = 99

  var body: some View {
    NavigationStack { //FIXME: remove nested navigation stack
      Divider()
      ScrollView {

        TagField(tags: $schedulerViewModel.workoutCategories,
                 set: $schedulerViewModel.selectedWorkoutCategory,
                 placeholder: "", prefix: "",
                 multiSelect: false,
                 isSelector: true)
        .accentColor(Color(.systemBlue))

        // select workout / body parts
        TagField(tags: $schedulerViewModel.workoutFocuses,
                 set: $schedulerViewModel.selectedWorkoutFocuses,
                 placeholder: "Other",
                 prefix: "",
                 multiSelect: true,
                 isSelector: false)
        .styled(.Modern)
        .accentColor(Color(.systemBlue))
        .padding()

        DatePicker("",
                   selection: $workoutTime,
                   in: Date()...,
                   displayedComponents: .hourAndMinute)
        .padding()
        .font(.headline)
        .fontWeight(.medium)
        .onTapGesture {
          viewModel.shouldShowTime = true
        }

        // set gym / workout location
        TagField(tags: $schedulerViewModel.gyms,
                 set: $schedulerViewModel.selectedGym,
                 placeholder: "Other",
                 prefix: "",
                 multiSelect: false,
                 isSelector: false)
        .styled(.Modern)
        .accentColor(Color(.systemBlue))
        .padding()

        // set workout comment / theme (perhaps image in the future)
        TextField("Add caption:", text: $workoutCaption, axis: .vertical)
          .padding()
          .padding(.bottom, 90)
          .font(.system(size: 18, weight: Font.Weight.medium, design: Font.Design.rounded))
          .lineLimit(2)
          .disableAutocorrection(true)
          .onReceive(Just(workoutCaption)) { _ in limitText(captionLengthLimit) }

        let slideButtonStyling = SlideButtonStyling(
          indicatorSize: 60,
          indicatorSpacing: 5,
          indicatorColor: .red,
          backgroundColor: .red.opacity(0.3),
          textColor: .secondary,
          indicatorSystemName: "trash",
          indicatorDisabledSystemName: "xmark",
          textAlignment: .globalCenter,
          textFadesOpacity: true,
          textHiddenBehindIndicator: true,
          textShimmers: false
        )

        if let session = viewModel.currentUserTrainingSesssion {
          SlideButton("Delete", styling: slideButtonStyling, action: {
            Task {
              viewModel.currentUserTrainingSesssion = nil //TODO: these 3 lines should be in the viewModel
              try await TrainingSessionService.deleteTrainingSession(withId: session.id)
              try await viewModel.fetchTrainingSessionsUpdateCache(forDay: viewModel.day)
            }
            dismiss()
          })
          .padding()
        }
      }
      .scrollDismissesKeyboard(.interactively)
      .keyboardAvoiding()
      .foregroundColor(.primary)
      .navigationTitle(viewModel.currentUserTrainingSesssion == nil ? "Add Workout" : "Edit Workout")
      .navigationBarTitleDisplayMode(.inline)
      .environmentObject(schedulerViewModel)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            guard !schedulerViewModel.selectedWorkoutFocuses.isEmpty else { return }

            Task {
              if let prevSession = viewModel.currentUserTrainingSesssion {

                let newSession = TrainingSession(id: prevSession.id,
                                                 ownerUid: user.id,
                                                 date: Timestamp(date: workoutTime),
                                                 focus: schedulerViewModel.selectedWorkoutFocuses,
                                                 location: schedulerViewModel.selectedGym.first,
                                                 caption: workoutCaption,
                                                 user: user, 
                                                 likes: prevSession.likes)

                let data = TrainingSessionViewData(
                  currentUserTrainingSession: newSession,
                  followingTrainingSessions: viewModel.trainingSessionsCache[viewModel.day.noon]?.followingTrainingSessions ?? []
                )
                viewModel.trainingSessionsCache[viewModel.day.noon] = data

                try await TrainingSessionService.updateTrainingSession(trainingSession: newSession)

              } else {
                let newSession = TrainingSession(id: "",
                                                 ownerUid: user.id,
                                                 date: Timestamp(date: workoutTime),
                                                 focus: schedulerViewModel.selectedWorkoutFocuses,
                                                 location: schedulerViewModel.selectedGym.first,
                                                 caption: workoutCaption,
                                                 user: user, 
                                                 likes: 0)

                let data = TrainingSessionViewData(
                  currentUserTrainingSession: newSession,
                  followingTrainingSessions: viewModel.trainingSessionsCache[viewModel.day.noon]?.followingTrainingSessions ?? []
                )
                viewModel.trainingSessionsCache[viewModel.day.noon] = data

                try await TrainingSessionService
                  .uploadTrainingSession(date: Timestamp(date: workoutTime),
                                         focus: schedulerViewModel.selectedWorkoutFocuses,
                                         location: schedulerViewModel.selectedGym.first,
                                         caption: workoutCaption,
                                         likes: 0)


              }
              try await viewModel.fetchTrainingSessionsUpdateCache(forDay: viewModel.day)
            }
            dismiss()
          } label: {
            Image(systemName: "checkmark.square.fill")

          }
          .foregroundColor(schedulerViewModel.selectedWorkoutFocuses.isEmpty ? .gray : .green)
        }
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            dismiss()
          } label: {
            Image(systemName: "x.square.fill")
          }
          .foregroundColor(.red)
        }
      }
    }.onAppear {
      if let session = viewModel.currentUserTrainingSesssion {
        workoutTime = session.date.dateValue()
        workoutCaption = session.caption ?? ""
        schedulerViewModel.selectedWorkoutFocuses = session.focus
        guard let location = session.location else { return }
        schedulerViewModel.selectedGym.append(location)
      } else {
        viewModel.shouldShowTime = false
        if Calendar.current.isDateInToday(viewModel.day) {
          workoutTime = viewModel.day.advancedToNextHour() ?? viewModel.day
        } else {
          workoutTime = viewModel.day.noon
        }
      }
      UIDatePicker.appearance().minuteInterval = 15
    }
    .onTapGesture {
      self.endTextEditing()
    }
  }

  func limitText(_ upper: Int) {
    if workoutCaption.count > upper {
      workoutCaption = String(workoutCaption.prefix(upper))
    }
  }
}

#Preview {
  TrainingSessionSchedulerView(user: User.MOCK_USERS[0])
}


extension View {
  func endTextEditing() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                    to: nil, from: nil, for: nil)
  }
}

public extension Publishers {
  static var keyboardHeight: AnyPublisher<CGFloat, Never> {
    let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
      .map { $0.keyboardHeight }
    let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
      .map { _ in CGFloat(0) }

    return MergeMany(willShow, willHide)
      .eraseToAnyPublisher()
  }
}

public extension Notification {
  var keyboardHeight: CGFloat {
    return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
  }
}

public struct KeyboardAvoiding: ViewModifier {
  @State private var keyboardActiveAdjustment: CGFloat = 0

  public func body(content: Content) -> some View {
    content
      .safeAreaInset(edge: .bottom, spacing: keyboardActiveAdjustment) {
        EmptyView().frame(height: 0)
      }
      .onReceive(Publishers.keyboardHeight) {
        self.keyboardActiveAdjustment = min($0, 66) // keyboard padding
      }
  }
}

public extension View {
  func keyboardAvoiding() -> some View {
    modifier(KeyboardAvoiding())
  }
}
