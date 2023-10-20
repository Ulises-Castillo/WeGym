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
      Task { async let _ = fetchTrainingSessionsUpdateCache(forDay: day) }
    }
  }

  //TODO: consider making this an array such that the user can have multiple training sessions scheduled in the same day (big for martial arts)
  @Published var currentUserTrainingSesssion: TrainingSession?
  @Published var shouldShowTime = true

  var isFirstFetch = true
  var isFetching = false // prevent redundant calls

  init() {
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
      currentUserTrainingSesssion = trainingSessionsCache[day]?.currentUserTrainingSession
      trainingSessions = trainingSessionsCache[day]?.followingTrainingSessions ?? []
    }
  }

  // return cached data immediately, if present
  // trigger cache update, background fetch
  // if not present (first fetch), wait for fetch
  // return data from fetch

//  func getTrainingSessions(forDay date: Date) async throws -> TrainingSessionViewData {
//    if let cachedData = trainingSessionsCache[date] {
//
//      async let _ = try await fetchTrainingSessionsUpdateCache(forDay: date)
//
//      return cachedData
//    } else {
//      
//      try await fetchTrainingSessionsUpdateCache(forDay: date)
//
//      return trainingSessionsCache[date] ?? 
//      TrainingSessionViewData(
//        currentUserTrainingSession: nil,
//        followingTrainingSessions: []
//      )
//    }
//  }

  @MainActor
  func fetchTrainingSessionsUpdateCache(forDay date: Date) async throws {
    var trainingSessions = try await TrainingSessionService.fetchTrainingSessions(forDay: date)

    var currentUserTrainingSession: TrainingSession?

    for i in 0..<trainingSessions.count {
      let session = trainingSessions[i]
      if let user = session.user, user.isCurrentUser {
        currentUserTrainingSession = session
        trainingSessions.remove(at: i)
        break
      }
    }

    let data = TrainingSessionViewData(
      currentUserTrainingSession: currentUserTrainingSession,
      followingTrainingSessions: trainingSessions
    )

    trainingSessionsCache[date] = data
  }


  @MainActor
  func fetchTrainingSessions() async throws {
    isFirstFetch = false
    guard !isFetching else { return }
    isFetching = true

    trainingSessions = try await TrainingSessionService.fetchTrainingSessions(forDay: day)

    var isFound = false

    for i in 0..<trainingSessions.count {
      let session = trainingSessions[i]
      if let user = session.user, user.isCurrentUser {
        currentUserTrainingSesssion = session
        trainingSessions.remove(at: i)
        isFound = true
        break
      }
    }
    if !isFound {
      currentUserTrainingSesssion = nil
    }

    isFetching = false
  }
}

struct TrainingSessionViewData {
  let currentUserTrainingSession: TrainingSession?
  let followingTrainingSessions: [TrainingSession]
}
