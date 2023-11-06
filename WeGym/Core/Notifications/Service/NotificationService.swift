//
//  NotificationService.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/19/23.
//

import Firebase

struct NotificationService {

    static func fetchNotifications() async -> [Notification2] {
        guard let uid = Auth.auth().currentUser?.uid else { return [] }

        let query = FirestoreConstants
            .NotificationsCollection
            .document(uid)
            .collection("user-notifications")
            .order(by: "timestamp", descending: true)

        guard let snapshot = try? await query.getDocuments() else { return [] }
        return snapshot.documents.compactMap({ try? $0.data(as: Notification2.self) })
    }

    static func uploadNotification(toUid uid: String, type: NotificationType, trainingSession: TrainingSession? = nil) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard uid != currentUid else { return }

        let notification = Notification2(trainingSessionId: trainingSession?.id, timestamp: Timestamp(), type: type, uid: currentUid)
        guard let data = try? Firestore.Encoder().encode(notification) else { return }

        FirestoreConstants
            .NotificationsCollection
            .document(uid)
            .collection("user-notifications")
            .addDocument(data: data)
    }

    static func deleteNotification(toUid uid: String, type: NotificationType, trainingSessionId: String? = nil) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }

        let snapshot = try await FirestoreConstants
            .NotificationsCollection
            .document(uid)
            .collection("user-notifications")
            .whereField("uid", isEqualTo: currentUid)
            .getDocuments()

        for document in snapshot.documents {
            let notification = try? document.data(as: Notification2.self)
            guard notification?.type == type else { return }

            if trainingSessionId != nil {
                guard trainingSessionId == notification?.trainingSessionId else { return }
            }

            try await document.reference.delete()
        }
    }

  static func resetBadgeCount() async {
    guard let currentUid = Auth.auth().currentUser?.uid else { return }

    do {
      try await FirestoreConstants.UserMetaCollection.document(currentUid).setData(["badgeCount" : 0], merge: true)
    } catch {
      print("*** resetBadgeCount error: \(error)")
    }
  }
}

