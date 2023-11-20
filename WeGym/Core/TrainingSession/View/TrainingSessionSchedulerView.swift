//
//  TrainingSessionSchedulerView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/15/23.
//

import SwiftUI
import Combine
import Firebase
import PhotosUI
import Kingfisher
import SlideButton

struct TrainingSessionSchedulerView: View {
  @State var workoutTime = Date()
  @State var workoutCaption = ""
  @State var workoutIsRecurring = false
  @State var workoutBroLimit = ""
  @State private var showingSearchSheet = false
  @FocusState var focusCaptionField: Bool

  @Environment(\.dismiss) var dismiss
  @EnvironmentObject var viewModel: TrainingSessionViewModel
  @StateObject var schedulerViewModel = TrainingSessionSchedulerViewModel()
  @State var timeTapped = false
  @State var isSubmitted = false

  let user: User
  let captionLengthLimit = 99

  var body: some View {
    NavigationStack { //FIXME: remove nested navigation stack
      Divider()
      ScrollView {
        VStack {

          TagField(tags: $schedulerViewModel.workoutCategories,
                   set: $schedulerViewModel.selectedWorkoutCategory,
                   placeholder: "", prefix: "",
                   multiSelect: false,
                   isSelector: true,
                   isPersonalRecord: false)
          .accentColor(Color(.systemBlue))
          .onAppear {
            if let session = viewModel.currentUserTrainingSesssion {
              schedulerViewModel.selectedWorkoutCategory = session.category
              schedulerViewModel.selectedWorkoutFocuses = session.focus
            }
          }

          // select workout / body parts
          TagField(tags: $schedulerViewModel.workoutFocuses,
                   set: $schedulerViewModel.selectedWorkoutFocuses,
                   placeholder: "Other",
                   prefix: "",
                   multiSelect: true,
                   isSelector: false,
                   isPersonalRecord: false)
          .styled(.Modern)
          .accentColor(Color(.systemBlue))
          .padding()

          HStack {
            PhotosPicker(selection: $schedulerViewModel.selectedImage) {
              if let image = schedulerViewModel.image {
                image
                  .resizable()
                  .scaledToFill()
                  .frame(width: 39, height: 39)
                  .clipped()
                  .cornerRadius(3)
                  .padding(.trailing, 33)
                  .padding(.top, 9)
              } else if let imageUrl = viewModel.currentUserTrainingSesssion?.imageUrl {
//                } else if let imageUrl = UserService.shared.currentUser?.profileImageUrl {
                KFImage(URL(string: imageUrl))
                  .placeholder {
                    Image(systemName: "photo")
                      .resizable()
                      .frame(width: 33, height: 33)
                      .clipped()
                      .foregroundColor(Color(.systemGray4))
                      .opacity(0.3)
                  }
                  .resizable()
                  .scaledToFill()
                  .frame(width: 39, height: 39)
                  .clipped()
                  .cornerRadius(3)
                  .padding(.trailing, 33)
                  .padding(.top, 9)
              } else {
                Image(systemName: "photo.badge.plus")
                  .resizable()
                  .frame(width: 39, height: 29)
                  .scaledToFill()
              }
            }
            .padding(.leading, 21)

            Spacer()

            DatePicker("",
                       selection: $workoutTime,
                       in: viewModel.day.startOfDay...viewModel.day.endOfDay, // only allow date within current day
                       displayedComponents: .hourAndMinute)
            .padding()
            .font(.headline)
            .fontWeight(.medium)
            .onTapGesture {
              timeTapped = true
              guard let currentUserId = UserService.shared.currentUser?.id else { return }
              viewModel.trainingSessionsCache[viewModel.key(currentUserId, viewModel.day)]?.shouldShowTime = true //TODO: test after new swipe animation changes
            }
          }

          // set gym / workout location
          TagField(tags: $schedulerViewModel.gyms,
                   set: $schedulerViewModel.selectedGym,
                   placeholder: "Other",
                   prefix: "",
                   multiSelect: false,
                   isSelector: false,
                   isPersonalRecord: false)
          .styled(.Modern)
          .accentColor(Color(.systemBlue))
          .padding()

          // set workout comment / theme (perhaps image in the future)
          TextField("", text: $workoutCaption, prompt: Text("Write a caption...").foregroundColor(.primary), axis: .vertical)
            .padding()
            .padding(.bottom, 90)
            .font(.system(size: 16, weight: Font.Weight.medium, design: Font.Design.rounded))
            .lineLimit(2)
            .disableAutocorrection(true)
            .onReceive(Just(workoutCaption)) { _ in limitText(captionLengthLimit) }
            .focused($focusCaptionField)
            .onTapGesture {
              focusCaptionField = true
            }

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

              guard let currUserId = UserService.shared.currentUser?.id else { return }
              guard !isSubmitted else { return }
              isSubmitted = true

              //TODO: delete training session from local cache immediately
              Task {
                viewModel.trainingSessionsCache[viewModel.key(currUserId, viewModel.day)] = nil
                try await viewModel.deleteTrainingSession(session: session)
              }
              dismiss()
            })
            .padding()
          }
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
            guard let currUserId = UserService.shared.currentUser?.id else { return }
            guard !schedulerViewModel.selectedWorkoutFocuses.isEmpty else { return }
            guard !isSubmitted else { return }
            isSubmitted = true

            Task {
              if let prevSession = viewModel.currentUserTrainingSesssion {

                let newSession = TrainingSession(id: prevSession.id,
                                                 ownerUid: user.id,
                                                 date: timeTapped ? Timestamp(date: workoutTime) : prevSession.date, //only set new time if new time was set, otherwise keep previous time
                                                 focus: schedulerViewModel.selectedWorkoutFocuses,
                                                 category: schedulerViewModel.selectedWorkoutCategory,
                                                 location: schedulerViewModel.selectedGym.first,
                                                 caption: workoutCaption,
                                                 user: user,
                                                 likes: prevSession.likes,
                                                 shouldShowTime: prevSession.shouldShowTime,
                                                 personalRecordIds: prevSession.personalRecordIds,
                                                 imageUrl: prevSession.imageUrl)

                viewModel.trainingSessionsCache[viewModel.key(currUserId, viewModel.day)] = newSession
                try await viewModel.updateTrainingSession(session: newSession)
                try await schedulerViewModel.updateImage(id: newSession.id)
              } else {
                let newSession = TrainingSession(id: "",
                                                 ownerUid: user.id,
                                                 date: Timestamp(date: workoutTime),
                                                 focus: schedulerViewModel.selectedWorkoutFocuses,
                                                 category: schedulerViewModel.selectedWorkoutCategory,
                                                 location: schedulerViewModel.selectedGym.first,
                                                 caption: workoutCaption,
                                                 user: user,
                                                 likes: 0,
                                                 shouldShowTime: timeTapped,
                                                 personalRecordIds: [])

                viewModel.trainingSessionsCache[viewModel.key(currUserId, viewModel.day)] = newSession
                try await viewModel.addTrainingSession(session: newSession)
                try await schedulerViewModel.updateImage(id: newSession.id)
              }

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
        guard let location = session.location else { return }
        schedulerViewModel.selectedGym.append(location)
      } else {
        if Calendar.current.isDateInToday(viewModel.day.advanced(by: 60*60*1.2)) { // prevent advancing to next day //TODO: test late at night
          workoutTime = viewModel.day.advancedToNextHour() ?? viewModel.day //TODO: time should default to the time user last set for that day of the week (could also count frequncy of that time on that day) [store in userdefaults]
        } else {                                                            // if no previous time for that specific day of the week, set last set time
          workoutTime = viewModel.day.noon                                  // if none then default to noon
        }                                                                   // also deal with workouts at / past 11pm, don't advance time one hour
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
