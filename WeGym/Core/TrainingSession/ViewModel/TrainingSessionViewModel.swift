//
//  TrainingSessionViewModel.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/17/23.
//

import Foundation


class TrainingSessionViewModel: ObservableObject {



  @Published var trainingSessions = [TrainingSession]()
  @Published var trainingSessionsCache2 = [String: TrainingSession]() {
    didSet {
      guard let currentUserId = UserService.shared.currentUser?.id else { return }
      currentUserTrainingSesssion = trainingSessionsCache2[key(currentUserId, day)]

      trainingSessions.removeAll()
      for session in trainingSessionsCache2.values.filter({ $0.ownerUid != currentUserId }) {
        trainingSessions.append(session)
      }
    }
  }

  func key(_ userID: String, _ date: Date) -> String {
    return userID + "\(date.noon)"
  }

  var day = Date.now {
    didSet {
      print("*** DAY set: \(day.formatted())")
      Task { try await observeTrainingSessions() }
      //      currentUserTrainingSesssion = trainingSessionsCache[day.noon]?.currentUserTrainingSession
      //      trainingSessions = trainingSessionsCache[day.noon]?.followingTrainingSessions ?? []

      //      Task { async let _ = fetchTrainingSessionsUpdateCache(forDay: day) }
      //      let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: day) ?? day //TODO: reduce duplication
      //      if trainingSessionsCache[tomorrow.noon] == nil {
      //        Task { async let _ = fetchTrainingSessionsUpdateCache(forDay: tomorrow) }
      //      }
      //      let dayAfterTmr = Calendar.current.date(byAdding: .day, value: 2, to: day) ?? day
      //      if trainingSessionsCache[dayAfterTmr.noon] == nil {
      //        Task { async let _ = fetchTrainingSessionsUpdateCache(forDay: dayAfterTmr) }
      //      }
      //      let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: day) ?? day
      //      if trainingSessionsCache[yesterday.noon] == nil {
      //        Task { async let _ = fetchTrainingSessionsUpdateCache(forDay: yesterday) }
      //      }
    }
  }

  //TODO: consider making this an array such that the user can have multiple training sessions scheduled in the same day (big for martial arts)
  @Published var currentUserTrainingSesssion: TrainingSession?
  @Published var shouldShowTime = true

  var isFirstFetch = [Date: Bool]()

  init() {
    //    Task { try await fetchTrainingSessionsUpdateCache(forDay: day) }
    Task { try await observeTrainingSessions() }
  }

  func observeTrainingSessions() async throws {
    try await TrainingSessionService.observeUserFollowingTrainingSessionsForDate(date: day) { [weak self] trainingSessions in
      guard let self = self else { return }


      for session in trainingSessions {
        var session = session
        session.user = UserService.shared.cache[session.ownerUid]
        trainingSessionsCache2[key(session.ownerUid, session.date.dateValue())] = session
      }
    }
  }

  func removeTrainingSessionListener() {
    TrainingSessionService.removeListener()
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
    relativeDateFormatter.locale = Locale(identifier: "en_US")
    relativeDateFormatter.doesRelativeDateFormatting = true

    guard let dayOfWeek = day.dayOfWeek(),
          let diff = Calendar.current.dateComponents([.day], from: day, to: Date()).day else { return "" }

    let relativeDate = relativeDateFormatter.string(from: day)
    let daySet: Set<String> = ["Yesterday", "Today", "Tomorrow"]

    if daySet.contains(relativeDate)  {
      return relativeDate
    } else if diff <= 6 && diff >= -6 {
      let calendar = Calendar.current
      if dayOfWeek == "Sunday" && diff > 0 {
        return "Past Sunday"
      } else if calendar.component(.weekOfYear, from: day) == calendar.component(.weekOfYear, from: Date()) {
        return dayOfWeek
      } else if diff > 0 {
        return "Past " + dayOfWeek
      } else if diff >= -6 && dayOfWeek == "Sunday" {
        return dayOfWeek
      } else {
        return "Next " + dayOfWeek
      }
    } else {
      return dayOfWeek + ", " + relativeDate.dropLast(6)
    }
  }

  @Published var trainingSessionsCache = [Date : TrainingSessionViewData]() {
    didSet {
      print("*** trainingSessionsCacheKeys: \(trainingSessionsCache.keys)")
      print("*** trainingSessionsCacheCount: \(trainingSessionsCache.count)")
      if currentUserTrainingSesssion != trainingSessionsCache[day.noon]?.currentUserTrainingSession {
        currentUserTrainingSesssion = trainingSessionsCache[day.noon]?.currentUserTrainingSession
      }
      if trainingSessions != trainingSessionsCache[day.noon]?.followingTrainingSessions ?? [] {
        trainingSessions = trainingSessionsCache[day.noon]?.followingTrainingSessions ?? []
      }
    }
  }

  @MainActor
  func fetchTrainingSessionsUpdateCache(forDay date: Date) async throws {
    guard let user = UserService.shared.currentUser else { return }
    var currentUserTrainingSession = try await TrainingSessionService.fetchUserTrainingSession(uid: user.id, date: date)
    currentUserTrainingSession?.user = user

    let followingTrainingSessions = try await TrainingSessionService.fetchUserFollowingTrainingSessions(uid: user.id, date: date)

    let data = TrainingSessionViewData(
      currentUserTrainingSession: currentUserTrainingSession,
      followingTrainingSessions: followingTrainingSessions
    )
    trainingSessionsCache[date.noon] = data
    isFirstFetch[date.noon] = false
  }
}

struct TrainingSessionViewData {
  let currentUserTrainingSession: TrainingSession?
  let followingTrainingSessions: [TrainingSession]
}
