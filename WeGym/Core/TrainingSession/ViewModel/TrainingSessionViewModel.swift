//
//  TrainingSessionViewModel.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/17/23.
//

import Foundation


class TrainingSessionViewModel: ObservableObject {

  @Published var trainingSessions = [TrainingSession]()
  public var day = Date.now {// changing this day and re-fetching will be the sauce
    didSet {
      currentUserTrainingSesssion = trainingSessionsCache[day.startOfDay]?.currentUserTrainingSession
      trainingSessions = trainingSessionsCache[day.startOfDay]?.followingTrainingSessions ?? []
      Task { async let _ = fetchTrainingSessionsUpdateCache(forDay: day) }
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
//      print("trainingSessionsCacheKeys: \(trainingSessionsCache.keys)")
//      print("trainingSessionsCacheCount: \(trainingSessionsCache.count)")
      currentUserTrainingSesssion = trainingSessionsCache[day.startOfDay]?.currentUserTrainingSession
      trainingSessions = trainingSessionsCache[day.startOfDay]?.followingTrainingSessions ?? []
    }
  }

  @MainActor
  func fetchTrainingSessionsUpdateCache(forDay date: Date) async throws {
    isFirstFetch = false
    guard !isFetching else { return }

    var currentUserTrainingSession = try await TrainingSessionService.fetchUserTrainingSession(uid: user.id, date: date)
    currentUserTrainingSession?.user = user
    self.currentUserTrainingSesssion = currentUserTrainingSession

    let followingTrainingSessions = try await TrainingSessionService.fetchUserFollowingTrainingSessions(uid: user.id, date: date) //TODO: fire at the same time?

    let data = TrainingSessionViewData(
      currentUserTrainingSession: currentUserTrainingSession,
      followingTrainingSessions: followingTrainingSessions
    )

    trainingSessionsCache[date.startOfDay] = data
    isFetching = false
  }
}

struct TrainingSessionViewData {
  let currentUserTrainingSession: TrainingSession?
  let followingTrainingSessions: [TrainingSession]
}
