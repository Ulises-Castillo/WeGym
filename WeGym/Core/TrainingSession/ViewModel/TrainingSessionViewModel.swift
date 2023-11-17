//
//  TrainingSessionViewModel.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/17/23.
//

import Firebase


class TrainingSessionViewModel: ObservableObject {

  var personalRecordsViewModel: PersonalRecordsViewModel?

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

  var currentUserTrainingSesssion: TrainingSession? {
    guard let currentUserId = UserService.shared.currentUser?.id else { return nil }
    return trainingSessionsCache[key(currentUserId, day)]
  }

  @Published var trainingSessions = [TrainingSession]()

  var userfollowingOrderLocal: [String]?

  //TODO: experiement with only calling this from observe listener completion instead of from setters (`didSet`) above
  // `reloadTrainingSessions()` being called too many times in rapid succession, though appears to be working fine for now
  func reloadTrainingSessions() { //TODO: consider how unfollowing would affect this flow
    guard let currentUser = UserService.shared.currentUser else { return }
    let currentUserTrainingSesssion = trainingSessionsCache[key(currentUser.id, day)]

    trainingSessions.removeAll()

    let order: [String]? = userfollowingOrderLocal != nil ? userfollowingOrderLocal : UserService.shared.currentUser?.userFollowingOrder

    if let order = order {
      //TODO: ensure we are recieving orer from the backend
      let followingTrainingSessions = trainingSessionsCache.values.filter({ $0.ownerUid != currentUser.id && $0.date.dateValue().noon == day.noon })

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
      for session in trainingSessionsCache.values.filter({ $0.ownerUid != currentUser.id }) {
        guard session.date.dateValue().noon == day.noon else { continue }
        trainingSessions.append(session)
      }
    }

    if let currentUserTrainingSesssion = currentUserTrainingSesssion {
      trainingSessions.insert(currentUserTrainingSesssion, at: 0)
    } else {
      var dummy = TrainingSession(id: dummyId, ownerUid: "", date: Timestamp(), focus: [], category: [], likes: 0, personalRecordIds: [])
      dummy.user = currentUser
      trainingSessions.insert(dummy, at: 0)
    }

    if personalRecordsViewModel != nil {
      for i in 0..<trainingSessions.count {
        let session = trainingSessions[i]

        for id in session.personalRecordIds {
          guard let pr = personalRecordsViewModel!.personalRecordsCache[id] else { continue }

          if trainingSessions[i].personalRecords?.append(pr) == nil {
            trainingSessions[i].personalRecords = [pr]
          }
        }
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
    try await TrainingSessionService.uploadTrainingSession(date: session.date,
                                                           focus: session.focus,
                                                           category: session.category,
                                                           location: session.location,
                                                           caption: session.caption,
                                                           likes: session.likes,
                                                           shouldShowTime: session.shouldShowTime,
                                                           personalRecordIds: session.personalRecordIds)
  }

  @MainActor
  func updateTrainingSession(session: TrainingSession) async throws {
    //    trainingSessionsCache2[key(session.ownerUid, day)] = session //TODO: consider updating session locally, immediately
    try await TrainingSessionService.updateTrainingSession(trainingSession: session)
  }

  func key(_ userID: String, _ date: Date) -> String {
    return userID + "\(date.noon)"
  }

  @MainActor
  func observeTrainingSessions() async throws {
    try await TrainingSessionService.observeUserFollowingTrainingSessionsForDate(date: day) { [weak self] (trainingSessions, removedTrainingSessions) in
      guard let self = self else { return }

      for session in removedTrainingSessions {
        trainingSessionsCache[key(session.ownerUid, session.date.dateValue())] = nil
      }

      Task { // fetch non-observed (non-current user) PRs
        if self.personalRecordsViewModel != nil {
          for session in trainingSessions {
            guard UserService.shared.currentUser?.id != session.ownerUid else { continue }

            for id in session.personalRecordIds {
//              guard self.personalRecordsViewModel!.personalRecordsCache[id] == nil else { continue }
              guard let pr = try await PersonalRecordService.fetchPersonalRecord(userId: session.ownerUid, prId: id) else { continue }
              self.personalRecordsViewModel!.personalRecordsCache[id] = pr
            }
            self.trainingSessionsCache[self.key(session.ownerUid, session.date.dateValue())] = session //FIX: update cache after (done due to the fact that the Task below may finish first)
          }
        }
      }

      Task {
        for session in trainingSessions {
          var session = session
          session.user = try await UserService.fetchUser(withUid: session.ownerUid, fromCache: true)
          self.trainingSessionsCache[self.key(session.ownerUid, session.date.dateValue())] = session
        }
        TrainingSessionService.updateHasBeenFetched()
      }
    }
  }

  func removeTrainingSessionListener() {
    TrainingSessionService.removeListener()
  }

  var userFollowingTimer: Timer?

  func setUserFollowingOrder() {
    let newOrder = trainingSessions.map({ $0.ownerUid }).dropFirst() // dropping first so as not to include current user
    userfollowingOrderLocal = Array(newOrder)

    userFollowingTimer?.invalidate()
    userFollowingTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { timer in
      Task { await TrainingSessionService.setUserFollowingOrder(self.userfollowingOrderLocal ?? []) }
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

  @Published var isShowingComment_TrainingSessionCell = false
  @Published var isShowingLikes_TrainingSessionCell = false

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
