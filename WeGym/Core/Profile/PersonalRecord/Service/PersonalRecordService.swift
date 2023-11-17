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

  static func observePersonalRecords(completion: @escaping([PersonalRecord], [PersonalRecord]) -> Void) async throws {

    // get user following + add current user
    guard let currentUser = UserService.shared.currentUser else { return }
    var userFollowing = try await UserService.fetchUserFollowing(uid: currentUser.id) //TODO: consider efficiency of double fetch (same call to observe training sessions)
    userFollowing.append(currentUser)

    let userFollowingIds: [String] = userFollowing.map({ $0.id })

    let query = FirestoreConstants
      .PersonalRecordsCollection
      .whereField("ownerUid", in: userFollowingIds)

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

  static func fetchPersonalRecord(prId: String) async throws -> PersonalRecord? {

    let query = FirestoreConstants
      .PersonalRecordsCollection
      .document(prId)

    let snapshot = try await query.getDocument()

    return try snapshot.data(as: PersonalRecord.self)
  }

  static func uploadPersonalRecord(_ personalRecord: PersonalRecord, trainingSession: TrainingSession?) async throws {

    let postRef = FirestoreConstants
      .PersonalRecordsCollection
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
    trainingSession.personalRecordIds.append(newPr.id)
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

    let query = FirestoreConstants
      .PersonalRecordsCollection
      .whereField("id", in: favPrIds)

    guard let snapshot = try? await query.getDocuments() else { return [] }
    let favPrs = snapshot.documents.compactMap({ try? $0.data(as: PersonalRecord.self) })
    return favPrs
  }

  static func updatePersonalRecord(_ personalRecord: PersonalRecord) async throws {
    guard let encodedPersonalRecord = try? Firestore.Encoder().encode(personalRecord) else { return }

    try await FirestoreConstants
      .PersonalRecordsCollection
      .document(personalRecord.id)
      .setData(encodedPersonalRecord)
  }

  static func deletePersonalRecord(withId id: String, _ trainingSession: TrainingSession?) async throws {

    try await FirestoreConstants
      .PersonalRecordsCollection
      .document(id)
      .delete()

    guard var trainingSession = trainingSession,
            let index = trainingSession.personalRecordIds.firstIndex(of: id) else { return }

    trainingSession.personalRecordIds.remove(at: index)
    try await TrainingSessionService.updateTrainingSession(trainingSession: trainingSession)
  }
}
