//
//  TrainingSessionViewModel.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/17/23.
//

import Foundation


class TrainingSessionViewModel: ObservableObject {

  @Published var trainingSessions = [TrainingSession]()
  var day = Date.now {
    didSet {
//      print("*** DAY set: \(day.formatted())")
      currentUserTrainingSesssion = trainingSessionsCache[day.noon]?.currentUserTrainingSession
      trainingSessions = trainingSessionsCache[day.noon]?.followingTrainingSessions ?? []
      if !isFirstFetch{
        Task { async let _ = fetchTrainingSessionsUpdateCache(forDay: day) }
      }
      let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: day) ?? day //TODO: reduce duplication
      if trainingSessionsCache[tomorrow.noon] == nil {
        Task { async let _ = fetchTrainingSessionsUpdateCache(forDay: tomorrow) }
      }
      let dayAfterTmr = Calendar.current.date(byAdding: .day, value: 2, to: day) ?? day
      if trainingSessionsCache[dayAfterTmr.noon] == nil {
        Task { async let _ = fetchTrainingSessionsUpdateCache(forDay: dayAfterTmr) }
      }
      let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: day) ?? day
      if trainingSessionsCache[yesterday.noon] == nil {
        Task { async let _ = fetchTrainingSessionsUpdateCache(forDay: yesterday) }
      }
    }
  }

  //TODO: consider making this an array such that the user can have multiple training sessions scheduled in the same day (big for martial arts)
  @Published var currentUserTrainingSesssion: TrainingSession?
  @Published var shouldShowTime = true

  let user: User

  var isFirstFetch = true
  var isFetching = false // prevent redundant calls

  init(user: User) {
    self.user = user
    Task { try await fetchTrainingSessionsUpdateCache(forDay: day) }
  }

  func beautifyWorkoutFocuses(focuses: [String]) -> [String] {
    var beautifiedFocuses = focuses
    // make set with BRO & PPL
    let categorySet = Set<String>(SchedulerConstants.workoutCategoryFocusesMap["BRO"]! +
                                  SchedulerConstants.workoutCategoryFocusesMap["PPL"]!)
    var majorFocus: String?

    // loop through selected focuses
    for focus in beautifiedFocuses {
      if categorySet.contains(focus) {
        if majorFocus != nil {
          return beautifiedFocuses
        } else {
          majorFocus = focus
        }
      }
    }
    // if only one tag from BRO or PPL found
    if var majorFocus = majorFocus {
      // remove original focus
      if let index = beautifiedFocuses.firstIndex(of: majorFocus) {
          beautifiedFocuses.remove(at: index)
      }
      // make singular, if plural
      if majorFocus.last == "s" {
        majorFocus = String(majorFocus.dropLast(1))
      }
      // append "Day"
      majorFocus = majorFocus + " Day"
      beautifiedFocuses.insert(majorFocus, at: 0)
    }
    return beautifiedFocuses
  }



  func relaiveDay() -> String {
    let relativeDateFormatter = DateFormatter()
    relativeDateFormatter.timeStyle = .none
    relativeDateFormatter.dateStyle = .medium
    relativeDateFormatter.locale = Locale(identifier: "en_GB")
    relativeDateFormatter.doesRelativeDateFormatting = true

    let inputFormatter = DateFormatter()
    inputFormatter.dateFormat = "yyyy-MM-dd"

    return relativeDateFormatter.string(from: day)
  }

  @Published var trainingSessionsCache = [Date : TrainingSessionViewData]() {
    didSet {
//      print("*** trainingSessionsCacheKeys: \(trainingSessionsCache.keys)")
//      print("*** trainingSessionsCacheCount: \(trainingSessionsCache.count)")
      currentUserTrainingSesssion = trainingSessionsCache[day.noon]?.currentUserTrainingSession
      trainingSessions = trainingSessionsCache[day.noon]?.followingTrainingSessions ?? []
    }
  }

  @MainActor
  func fetchTrainingSessionsUpdateCache(forDay date: Date) async throws {
    var currentUserTrainingSession = try await TrainingSessionService.fetchUserTrainingSession(uid: user.id, date: date)
    currentUserTrainingSession?.user = user

    let followingTrainingSessions = try await TrainingSessionService.fetchUserFollowingTrainingSessions(uid: user.id, date: date)

    let data = TrainingSessionViewData(
      currentUserTrainingSession: currentUserTrainingSession,
      followingTrainingSessions: followingTrainingSessions
    )
    trainingSessionsCache[date.noon] = data
    isFirstFetch = false
  }
}

struct TrainingSessionViewData {
  let currentUserTrainingSession: TrainingSession?
  let followingTrainingSessions: [TrainingSession]
}
