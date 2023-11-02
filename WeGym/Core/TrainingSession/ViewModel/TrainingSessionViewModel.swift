//
//  TrainingSessionViewModel.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/17/23.
//

import Foundation


class TrainingSessionViewModel: ObservableObject {

  var day = Date.now {
    didSet {
      reloadTrainingSessions()
      Task { async let _ = observeTrainingSessions() }
    }
  }

  @Published var trainingSessionsCache = [String: TrainingSession]() {
    didSet {
      reloadTrainingSessions()
    }
  }

  @Published var currentUserTrainingSesssion: TrainingSession?
  @Published var trainingSessions = [TrainingSession]()

  func reloadTrainingSessions() {
    guard let currentUserId = UserService.shared.currentUser?.id else { return }
    currentUserTrainingSesssion = trainingSessionsCache[key(currentUserId, day)]

    trainingSessions.removeAll()
    for session in trainingSessionsCache.values.filter({ $0.ownerUid != currentUserId }) {
      guard session.date.dateValue().noon == day.noon else { continue }
      trainingSessions.append(session)
    }
  }

  @MainActor
  func deleteTrainingSession(session: TrainingSession) async throws {
    //    trainingSessionsCache2[key(session.ownerUid, day)] = nil //TODO: consider deleting session locally, immediately
    try await TrainingSessionService.deleteTrainingSession(withId: session.id)
  }

  @MainActor
  func addTrainingSession(session: TrainingSession) async throws { //TODO: works well, however consider adding session locally immediate (offline mode will require this certainly)
    try await TrainingSessionService.uploadTrainingSession(date: session.date, focus: session.focus, location: session.location, caption: session.caption, likes: session.likes)
  }

  @MainActor
  func updateTrainingSession(session: TrainingSession) async throws {
    //    trainingSessionsCache2[key(session.ownerUid, day)] = session //TODO: consider updating session locally, immediately
    try await TrainingSessionService.updateTrainingSession(trainingSession: session)
  }

  func key(_ userID: String, _ date: Date) -> String {
    return userID + "\(date.noon)"
  }

  @Published var shouldShowTime = true

  var isFirstFetch = [Date: Bool]() //TODO: improve to account for the fact this is only being set when a training session IS scheduled for a certain date. In other words, Rest day cells will still take a sec to load (show spinner) because nothing was returned for those days.

  @MainActor
  func observeTrainingSessions() async throws {
    try await TrainingSessionService.observeUserFollowingTrainingSessionsForDate(date: day) { [weak self] (trainingSessions, removedTrainingSessions) in
      guard let self = self else { return }

      print("*** Listener update: \(trainingSessions.count)")

      for session in removedTrainingSessions {
        trainingSessionsCache[key(session.ownerUid, session.date.dateValue())] = nil
      }

      for session in trainingSessions {
        var session = session
        session.user = UserService.shared.cache[session.ownerUid]
        trainingSessionsCache[key(session.ownerUid, session.date.dateValue())] = session
      }
      isFirstFetch[day.noon] = false
    }
  }

  func removeTrainingSessionListener() {
    TrainingSessionService.removeListener()
  }

  @Published var commentsCountCache = [String: Int]()

  @MainActor
  func updateCommentsCountCache(trainingSessionId: String) async throws {
    let count = try await CommentService.commentsCount(id: trainingSessionId)
    commentsCountCache[trainingSessionId] = count
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
}
