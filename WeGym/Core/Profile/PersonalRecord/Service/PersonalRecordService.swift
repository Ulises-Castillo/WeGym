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

  static func uploadPersonalRecord(_ personalRecord: PersonalRecord) async throws {
    guard let uid = Auth.auth().currentUser?.uid else { return }

    let postRef = FirestoreConstants.UserCollection
      .document(uid)
      .collection("personal-records")
      .document()

    var newPr = PersonalRecord(id: postRef.documentID,
                               weight: personalRecord.weight,
                               reps: personalRecord.reps,
                               category: personalRecord.category,
                               type: personalRecord.type,
                               ownerUid: personalRecord.ownerUid,
                               timestamp: personalRecord.timestamp,
                               notes: personalRecord.notes)

    guard let encodedPersonalRecord = try? Firestore.Encoder().encode(newPr) else { return }
    try await postRef.setData(encodedPersonalRecord)
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

  static func deletePersonalRecord(withId id: String) async throws {
    guard let uid = Auth.auth().currentUser?.uid else { return }

    try await FirestoreConstants.UserCollection
      .document(uid)
      .collection("personal-records")
      .document(id)
      .delete()
  }
}
