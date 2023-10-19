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
  static func fetchTrainingSessions(forDay: Date) async throws -> [TrainingSession] { //TODO: test
    
    let start = Timestamp(date: forDay.startOfDay)
    let end = Timestamp(date: forDay.endOfDay)
    
    let snapshot = try await Firestore.firestore().collection("training_sessions").whereField("date", isGreaterThan: start).whereField("date", isLessThan: end).getDocuments()
    
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
    let postRef = Firestore.firestore().collection("training_sessions").document()
    
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
    try await Firestore.firestore().collection("training_sessions").document(trainingSession.id).setData(encodedTrainingSession)
  }

  static func deleteTrainingSession(withId id: String) async throws {
    try await Firestore.firestore().collection("training_sessions").document(id).delete()
  }
}

//TODO: move to appropriate location
extension Date {
  var startOfDay: Date {
    return Calendar.current.startOfDay(for: self)
  }
  
  var endOfDay: Date {
    var components = DateComponents()
    components.day = 1
    components.second = -1
    return Calendar.current.date(byAdding: components, to: startOfDay)!
  }
}
