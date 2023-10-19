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

        // set workout time
        //TODO: start date range should round up to the next 30min / hour
        DatePicker("Time:", 
                   selection: $workoutTime,
                   in: Date()...,
                   displayedComponents: .hourAndMinute)
          .padding()
          .font(.title3)
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
        TextField("Caption:", text: $workoutCaption, axis: .vertical)
          .padding()
          .padding(.bottom, 90)
          .font(.title3)
          .lineLimit(2)

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
              viewModel.currentUserTrainingSesssion = nil
              try await TrainingSessionService.deleteTrainingSession(withId: session.id)
              try await viewModel.fetchTrainingSessions()
            }
            dismiss()
          })
          .padding()
        }
      }
      .foregroundColor(.primary)
      .navigationTitle(viewModel.currentUserTrainingSesssion == nil ? "Add Workout" : "Edit Workout")
      .navigationBarTitleDisplayMode(.inline)
      .environmentObject(schedulerViewModel)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            Task {


              if let prevSession = viewModel.currentUserTrainingSesssion {

                let newSession = TrainingSession(id: prevSession.id,
                                                 ownerUid: user.id,
                                                 date: Timestamp(date: workoutTime),
                                                 focus: schedulerViewModel.selectedWorkoutFocuses,
                                                 location: schedulerViewModel.selectedGym.first,
                                                 caption: workoutCaption,
                                                 user: user)

                try await TrainingSessionService.updateTrainingSession(trainingSession: newSession)

              } else {
                try await TrainingSessionService
                  .uploadTrainingSession(date: Timestamp(date: workoutTime),
                                         focus: schedulerViewModel.selectedWorkoutFocuses,
                                         location: schedulerViewModel.selectedGym.first,
                                         caption: workoutCaption)

                viewModel.currentUserTrainingSesssion = TrainingSession(id: "",
                                                                        ownerUid: "",
                                                                        date: Timestamp(date: workoutTime),
                                                                        focus: schedulerViewModel.selectedWorkoutFocuses,
                                                                        location: schedulerViewModel.selectedGym.first,
                                                                        caption: workoutCaption,
                                                                        user: user)
              }
              try await viewModel.fetchTrainingSessions()
            }
            dismiss()
          } label: {
            Image(systemName: "checkmark")
          }
          .foregroundColor(.green)
        }
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            dismiss()
          } label: {
            Image(systemName: "xmark")
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
        workoutTime = viewModel.day.advancedToNextHour() ?? viewModel.day
      }
    }
    .onTapGesture {
      self.endTextEditing()
    }
  }

}

#Preview {
  TrainingSessionSchedulerView(user: User.MOCK_USERS[0])
}


//TODO: move to appropirate place for extensions, constant, etc.
extension View {
  func endTextEditing() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                    to: nil, from: nil, for: nil)
  }
}

extension Date {
  func advancedToNextHour() -> Date? {
    var date = self
    date += TimeInterval(59*60+59)
    let calendar = Calendar.current
    let components = calendar.dateComponents([.second, .minute], from: date)
    guard let minutes = components.minute,
          let seconds = components.second else {
      return nil
    }
    return date - TimeInterval(minutes)*60 - TimeInterval(seconds)
  }
}
