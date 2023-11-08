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

  var userfollowingOrderLocal: [String]?

  func reloadTrainingSessions() { //TODO: consider how unfollowing would affect this flow
    guard let currentUserId = UserService.shared.currentUser?.id else { return }
    currentUserTrainingSesssion = trainingSessionsCache[key(currentUserId, day)]

    trainingSessions.removeAll()

    let order: [String]? = userfollowingOrderLocal != nil ? userfollowingOrderLocal : UserService.shared.currentUser?.userFollowingOrder

    if let order = order {
      //TODO: ensure we are recieving orer from the backend
      let followingTrainingSessions = trainingSessionsCache.values.filter({ $0.ownerUid != currentUserId && $0.date.dateValue().noon == day.noon })

      for uid in order {
        for session in followingTrainingSessions {
          if session.ownerUid == uid {
            trainingSessions.append(session)
            break
          }
        }
      }
      // account for a new follower who would not be found
      // by adding any remaining session
      for session in followingTrainingSessions {
        if !trainingSessions.contains(session) {
          trainingSessions.append(session)
        }
      }

    } else {
      for session in trainingSessionsCache.values.filter({ $0.ownerUid != currentUserId }) {
        guard session.date.dateValue().noon == day.noon else { continue }
        trainingSessions.append(session)
      }
    }

    Task {
      for session in trainingSessionsCache.values {
        guard didLikeCache[session.id] == nil else { continue }
        await checkIfUserLikedTrainingSession(id: session.id)
      }

      for session in trainingSessionsCache.values {
        guard commentsCountCache[session.id] == nil else { continue }
        await updateCommentsCountCache(trainingSessionId: session.id)
      }
    }
  }

  @MainActor
  func deleteTrainingSession(session: TrainingSession) async throws {
    //    trainingSessionsCache2[key(session.ownerUid, day)] = nil //TODO: consider deleting session locally, immediately
    try await TrainingSessionService.deleteTrainingSession(withId: session.id)
  }

  @MainActor
  func addTrainingSession(session: TrainingSession) async throws { //TODO: works well, however consider adding session locally immediate (offline mode will require this certainly)
    try await TrainingSessionService.uploadTrainingSession(date: session.date, focus: session.focus, location: session.location, caption: session.caption, likes: session.likes, shouldShowTime: session.shouldShowTime)
  }

  @MainActor
  func updateTrainingSession(session: TrainingSession) async throws {
    //    trainingSessionsCache2[key(session.ownerUid, day)] = session //TODO: consider updating session locally, immediately
    try await TrainingSessionService.updateTrainingSession(trainingSession: session)
  }

  func key(_ userID: String, _ date: Date) -> String {
    return userID + "\(date.noon)"
  }

//  @Published var shouldShowTime = true //TODO: replace properly

  var isFirstFetch = [Date: Bool]() //TODO: improve to account for the fact this is only being set when a training session IS scheduled for a certain date. In other words, Rest day cells will still take a sec to load (show spinner) because nothing was returned for those days.

  @MainActor
  func observeTrainingSessions() async throws {
    try await TrainingSessionService.observeUserFollowingTrainingSessionsForDate(date: day) { [weak self] (trainingSessions, removedTrainingSessions) in
      guard let self = self else { return }

      print("*** Listener update: \(trainingSessions.count)")

      for session in removedTrainingSessions {
        trainingSessionsCache[key(session.ownerUid, session.date.dateValue())] = nil
      }

      Task {
        for session in trainingSessions {
          var session = session
          session.user = try await UserService.fetchUser(withUid: session.ownerUid)
          self.trainingSessionsCache[self.key(session.ownerUid, session.date.dateValue())] = session
        }
        self.isFirstFetch[self.day.noon] = false
      }
    }
  }

  func removeTrainingSessionListener() {
    TrainingSessionService.removeListener()
  }

  var userFollowingTimer: Timer?

  func setUserFollowingOrder() {
    let newOrder = trainingSessions.map({ $0.ownerUid })
    userfollowingOrderLocal = newOrder

    userFollowingTimer?.invalidate()
    userFollowingTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { timer in
      Task { await TrainingSessionService.setUserFollowingOrder(newOrder) }
    }
  }

  // Makes more sense to have these separate from the main cache due to how the data is structured
  @Published var commentsCountCache = [String: Int]()
  @Published var didLikeCache = [String: Bool]()

  @MainActor
  func checkIfUserLikedTrainingSession(id: String) async {
    guard !id.isEmpty else { return } // required to prevent CRASH on new session (no id yet)
    do {
      didLikeCache[id] = try await TrainingSessionService.checkIfUserLikedTrainingSession(id)
    } catch {
      print(error)
    }
  }

  @MainActor
  func like(_ trainingSession: TrainingSession) async { // pass in from cache // across the board deal only with cached session
    do {
      didLikeCache[trainingSession.id] = true
      trainingSessionsCache[key(trainingSession.ownerUid, trainingSession.date.dateValue())]?.likes += 1
      try await TrainingSessionService.likeTrainingSession(trainingSession) //TODO: send the cached training session
    } catch {
      didLikeCache[trainingSession.id] = false
      trainingSessionsCache[key(trainingSession.ownerUid, trainingSession.date.dateValue())]?.likes -= 1
    }
  }

  @MainActor
  func unlike(_ trainingSession: TrainingSession) async {
    do {
      didLikeCache[trainingSession.id] = false
      trainingSessionsCache[key(trainingSession.ownerUid, trainingSession.date.dateValue())]?.likes -= 1
      try await TrainingSessionService.unlikeTrainingSession(trainingSession)
    } catch {
      didLikeCache[trainingSession.id] = true
      trainingSessionsCache[key(trainingSession.ownerUid, trainingSession.date.dateValue())]?.likes += 1
    }
  }


  @MainActor
  func updateCommentsCountCache(trainingSessionId: String) async {
    do {
      let count = try await CommentService.commentsCount(id: trainingSessionId)
      commentsCountCache[trainingSessionId] = count
    } catch {
      print(error)
    }
  }

  func defaultDay() -> (Date, Bool) { //account for session scheduled late at night, say 11pm
    if let user = UserService.shared.currentUser, let currUserSession = trainingSessionsCache[key(user.id, Date())] {
      let workoutEnd = currUserSession.date.dateValue().addingTimeInterval(60*60*2)     // uncomment
//      let workoutEnd = currUserSession.date.dateValue().addingTimeInterval(-60*60*6)  // comment TEST ONLY
      if Date().timeIntervalSince1970 > workoutEnd.timeIntervalSince1970 {
        return (currUserSession.date.dateValue().addingTimeInterval(60*60*24).noon, true)
      }
    }
    return (Date(), false)
  }
}
