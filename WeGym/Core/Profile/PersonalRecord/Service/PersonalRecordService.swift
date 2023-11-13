//
//  PersonalRecordService.swift
//  WeGym
//
//  Created by Ulises Castillo on 11/4/23.
//

import Foundation
import Firebase

struct PersonalRecordService {

  static private var firestoreListener: ListenerRegistration?

  static func observePersonalRecords(completion: @escaping([PersonalRecord], [PersonalRecord]) -> Void) {
    guard let uid = Auth.auth().currentUser?.uid else { return }

    let query = FirestoreConstants.UserCollection
      .document(uid)
      .collection("personal-records")
      .order(by: "timestamp", descending: true)

    self.firestoreListener = query.addSnapshotListener { snapshot, _ in

      guard let changes = snapshot?.documentChanges else { return }

      var personalRecords = [PersonalRecord]()
      var removedPersonalRecords = [PersonalRecord]()

      for change in changes {
        guard let personalRecord = try? change.document.data(as: PersonalRecord.self) else { continue }

        if change.type == .removed {
          removedPersonalRecords.append(personalRecord)
        } else {
          personalRecords.append(personalRecord)
        }
      }
      completion(personalRecords, removedPersonalRecords)
    }
  }

  static func removeListener() {
    self.firestoreListener?.remove()
    self.firestoreListener = nil
  }

  static func uploadPersonalRecord(_ personalRecord: PersonalRecord, trainingSession: TrainingSession?) async throws {
    guard let uid = Auth.auth().currentUser?.uid else { return }

    let postRef = FirestoreConstants.UserCollection
      .document(uid)
      .collection("personal-records")
      .document()

    let newPr = PersonalRecord(id: postRef.documentID,
                               weight: personalRecord.weight,
                               reps: personalRecord.reps,
                               category: personalRecord.category,
                               type: personalRecord.type,
                               ownerUid: personalRecord.ownerUid,
                               timestamp: personalRecord.timestamp,
                               notes: personalRecord.notes)

    guard let encodedPersonalRecord = try? Firestore.Encoder().encode(newPr) else { return }
    try await postRef.setData(encodedPersonalRecord)

    guard var trainingSession = trainingSession else { return }
    trainingSession.personRecordIds.append(newPr.id)
    try await TrainingSessionService.updateTrainingSession(trainingSession: trainingSession)
  }

  static func uploadFavoritePersonalRecordIds(_ favPrIds: [String]) async throws {
    guard let uid = Auth.auth().currentUser?.uid else { return }

    let postRef = FirestoreConstants.UserMetaCollection.document(uid)
    try await postRef.setData(["favPrIds": favPrIds], merge: true)
  }

  static func fetchFavoritePersonalRecords(userId: String) async throws -> [PersonalRecord] {

    let snapshot = try await FirestoreConstants.UserMetaCollection.document(userId).getDocument()
    guard let data = snapshot.data(), let favPrIds = data["favPrIds"] as? [String], !favPrIds.isEmpty else { return [] }

    print("*** favPrIds: \(favPrIds)")

    let query = FirestoreConstants.UserCollection
      .document(userId)
      .collection("personal-records")
      .whereField("id", in: favPrIds)

    guard let snapshot = try? await query.getDocuments() else { return [] }
    let favPrs = snapshot.documents.compactMap({ try? $0.data(as: PersonalRecord.self) })
    return favPrs
  }

  static func updatePersonalRecord(_ personalRecord: PersonalRecord) async throws {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    guard let encodedPersonalRecord = try? Firestore.Encoder().encode(personalRecord) else { return }

    try await FirestoreConstants.UserCollection
      .document(uid)
      .collection("personal-records")
      .document(personalRecord.id)
      .setData(encodedPersonalRecord)
  }

  static func deletePersonalRecord(withId id: String, _ trainingSession: TrainingSession?) async throws {
    guard let uid = Auth.auth().currentUser?.uid else { return }

    try await FirestoreConstants.UserCollection
      .document(uid)
      .collection("personal-records")
      .document(id)
      .delete()

    guard var trainingSession = trainingSession,
            let index = trainingSession.personRecordIds.firstIndex(of: id) else { return }
    
    trainingSession.personRecordIds.remove(at: index)
    try await TrainingSessionService.updateTrainingSession(trainingSession: trainingSession)
  }
}
