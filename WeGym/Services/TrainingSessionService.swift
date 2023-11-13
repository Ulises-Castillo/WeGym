//
//  TrainingSessionService.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/16/23.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct TrainingSessionService {
  static private var fetchedDates = [ClosedRange<Date>]()

  static func hasBeenFetched(date: Date) -> Bool { //TODO: merge overlapping date ranges
    let noon = date.noon

    for range in fetchedDates {
      if range.contains(noon) {
        return true
      }
    }
    return false
  }

  static var start: Timestamp?
  static var end: Timestamp?

  static func updateHasBeenFetched() {
    guard let start = start, let end = end else { return }
    fetchedDates.append(start.dateValue()...end.dateValue())
    self.start = nil
    self.end = nil
  }

  static func clearFetchedDates() {
    fetchedDates.removeAll()
  }

  static private var firestoreListener: ListenerRegistration?

  static func observeUserFollowingTrainingSessionsForDate(date: Date, completion: @escaping([TrainingSession], [TrainingSession]) -> Void) async throws {
    // also need to observe current user for date (consider local updates etc) can use [user+date] as ID to update actual ID when create call returns

    // get user following + add current user
    guard let currentUser = UserService.shared.currentUser else { return }
    var userFollowing = try await UserService.fetchUserFollowing(uid: currentUser.id) //TODO: cache users
    userFollowing.append(currentUser)

    var userFollowingIds: [String] = userFollowing.map({ $0.id })
    userFollowingIds.append(currentUser.id)

    guard let prevWeek = Calendar.current.date(byAdding: .day, value: -7, to: date),
          let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: date) else { return }

    start = Timestamp(date: prevWeek.startOfDay)
    end = Timestamp(date: nextWeek.endOfDay)

    let query = FirestoreConstants.TrainingSessionsCollection
      .whereField("ownerUid", in: userFollowingIds)
      .whereField("date", isGreaterThan: start!)
      .whereField("date", isLessThan: end!)
      .order(by: "date", descending: false) //TODO: add user-selected ordering field (?)

    self.firestoreListener = query.addSnapshotListener { snapshot, _ in
      guard let changes = snapshot?.documentChanges else { return }
      var trainingSessions = [TrainingSession]()
      var removedTrainingSessions = [TrainingSession]()

      for change in changes {
        guard let trainingSession = try? change.document.data(as: TrainingSession.self) else { continue }

        if change.type == .removed {
          removedTrainingSessions.append(trainingSession)
        } else {
          trainingSessions.append(trainingSession)
        }
      }

      for i in 0..<trainingSessions.count {
        trainingSessions[i].user = userFollowing.filter({ $0.id == trainingSessions[i].ownerUid }).first //TODO: make more efficient by making the map beforehand (should be using UserService cache anyway)
      }

      completion(trainingSessions, removedTrainingSessions)
    }
  }

  static func removeListener() {
    self.firestoreListener?.remove()
    self.firestoreListener = nil
  }

  static func fetchTrainingSessions(forDay: Date) async throws -> [TrainingSession] {

    let start = Timestamp(date: forDay.startOfDay)
    let end = Timestamp(date: forDay.endOfDay)

    let snapshot = try await FirestoreConstants
      .TrainingSessionsCollection
      .whereField("date", isGreaterThan: start)
      .whereField("date", isLessThan: end)
      .getDocuments()

    var trainingSessions = snapshot.documents.compactMap({ try? $0.data(as: TrainingSession.self) })

    for i in 0..<trainingSessions.count {
      let session = trainingSessions[i]
      let ownerUid = session.ownerUid
      let sessionUser = try await UserService.fetchUser(withUid: ownerUid)
      // Single Source of Truth on the backend
      // setting the user on the post such that the user info will be up to date
      // yes, we could store username etc. w/ Post, however consider what would
      // happen if the user had changed thier info (name, etc.) since making the
      // Post. The user info stored with the Post would be outdated
      trainingSessions[i].user = sessionUser
    }
    return trainingSessions
  }

  static func uploadTrainingSession(date: Timestamp, focus: [String], category: [String], location: String?, caption: String?, likes: Int, shouldShowTime: Bool, personalRecordIds: [String]) async throws {

    guard let uid = Auth.auth().currentUser?.uid else { return }
    let postRef = FirestoreConstants.TrainingSessionsCollection.document()

    let trainingSession = TrainingSession(id: postRef.documentID,
                                          ownerUid: uid,
                                          date: date,
                                          focus: focus,
                                          category: category,
                                          location: location,
                                          caption: caption,
                                          likes: likes,
                                          shouldShowTime: shouldShowTime,
                                          personalRecordIds: personalRecordIds)

    guard let encodedTrainingSession = try? Firestore.Encoder().encode(trainingSession) else { return }
    try await postRef.setData(encodedTrainingSession)
  }

  static func updateTrainingSession(trainingSession: TrainingSession) async throws {

    var session = trainingSession; session.user = nil // no need to store possibly soon-to-be-stale user info
    guard let encodedTrainingSession = try? Firestore.Encoder().encode(session) else { return }
    try await FirestoreConstants.TrainingSessionsCollection.document(session.id).setData(encodedTrainingSession)
  }

  static func deleteTrainingSession(withId id: String) async throws {
    try await FirestoreConstants.TrainingSessionsCollection.document(id).delete()
  }
}

extension TrainingSessionService {
  static func fetchUserTrainingSession(uid: String, date: Date) async throws -> TrainingSession? {

    let start = Timestamp(date: date.startOfDay)
    let end = Timestamp(date: date.endOfDay)

    async let snapshot = FirestoreConstants
      .TrainingSessionsCollection
      .whereField("ownerUid", isEqualTo: uid)
      .whereField("date", isGreaterThan: start)
      .whereField("date", isLessThan: end)
      .getDocuments()

    return try await snapshot.documents.compactMap({ try? $0.data(as: TrainingSession.self) }).first
  }

  static func fetchUserTrainingSession(uid: String) async throws -> TrainingSession? {

    async let snapshot = FirestoreConstants
      .TrainingSessionsCollection
      .document(uid)
      .getDocument()

    return try await snapshot.data(as: TrainingSession.self)
  }

  static func fetchUserFollowingTrainingSessions(uid: String, date: Date) async throws -> [TrainingSession] {

    let following = try await UserService.fetchUserFollowing(uid: uid)

    var trainingSessions = [TrainingSession]()
    for followee in following {
      async let session = try await fetchUserTrainingSession(uid: followee.id, date: date)
      if var session = try await session {
        session.user = followee
        trainingSessions.append(session)
      }
    }
    return trainingSessions
  }

  static func setUserFollowingOrder(_ newOrder: [String]) async {
    guard let uid = Auth.auth().currentUser?.uid else { return }

    do { //TODO: consider moving a different collection becuase this could grow large and is not needed for all users to download to every user (unneccessary data size)
      try await FirestoreConstants.UserCollection.document(uid).setData(["userFollowingOrder" : newOrder], merge: true) //TODO: test repeated calls
    } catch {
      print("*** \(error)")
    }
  }
}

// MARK: - Likes

extension TrainingSessionService {
  static func likeTrainingSession(_ trainingSession: TrainingSession) async throws {
    guard let uid = Auth.auth().currentUser?.uid,
          !trainingSession.id.isEmpty else { return } //FIXME: user liking his own post immediatedly after creating it will be ignored // simple solution: disable action buttons for a sec after workout creation


    async let _ = try await FirestoreConstants.TrainingSessionsCollection.document(trainingSession.id).collection("training_session-likes").document(uid).setData([:])
    async let _ = try await FirestoreConstants.TrainingSessionsCollection.document(trainingSession.id).updateData(["likes": trainingSession.likes + 1])
    async let _ = try await FirestoreConstants.UserCollection.document(uid).collection("user-likes").document(trainingSession.id).setData([:])

    async let _ = NotificationService.uploadNotification(toUid: trainingSession.ownerUid, type: .like, trainingSession: trainingSession)
  }

  static func unlikeTrainingSession(_ trainingSession: TrainingSession) async throws {
    guard let uid = Auth.auth().currentUser?.uid else { return }

    async let _ = try await FirestoreConstants.TrainingSessionsCollection.document(trainingSession.id).collection("training_session-likes").document(uid).delete()
    async let _ = try await FirestoreConstants.TrainingSessionsCollection.document(trainingSession.id).updateData(["likes": trainingSession.likes - 1])
    async let _ = try await FirestoreConstants.UserCollection.document(uid).collection("user-likes").document(trainingSession.id).delete()

    async let _ = NotificationService.deleteNotification(toUid: trainingSession.ownerUid, type: .like, trainingSessionId: trainingSession.id)
  }

  static func checkIfUserLikedTrainingSession(_ id: String) async throws -> Bool {
    guard let uid = Auth.auth().currentUser?.uid else { return false }

    let snapshot = try await FirestoreConstants.UserCollection.document(uid).collection("user-likes").document(id).getDocument()
    return snapshot.exists
  }
}
