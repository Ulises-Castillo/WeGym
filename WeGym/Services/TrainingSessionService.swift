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
    
    return snapshot.documents.compactMap({ try? $0.data(as: TrainingSession.self) })
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
