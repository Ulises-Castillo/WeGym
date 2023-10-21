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
  
  static func uploadTrainingSession(date: Timestamp, focus: [String], location: String?, caption: String?) async throws {
    
    guard let uid = Auth.auth().currentUser?.uid else { return }
    let postRef = FirestoreConstants.TrainingSessionsCollection.document()

    let trainingSession = TrainingSession(id: postRef.documentID,
                                          ownerUid: uid,
                                          date: date,
                                          focus: focus,
                                          location: location,
                                          caption: caption)
    
    guard let encodedTrainingSession = try? Firestore.Encoder().encode(trainingSession) else { return }
    try await postRef.setData(encodedTrainingSession)
  }
  
  static func updateTrainingSession(trainingSession: TrainingSession) async throws {
    
    guard let encodedTrainingSession = try? Firestore.Encoder().encode(trainingSession) else { return }
    try await FirestoreConstants.TrainingSessionsCollection.document(trainingSession.id).setData(encodedTrainingSession)
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
}
