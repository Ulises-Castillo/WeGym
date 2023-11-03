//
//  Notification.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/19/23.
//

import FirebaseFirestoreSwift
import Firebase

struct Notification2: Identifiable, Codable {
    @DocumentID var id: String?
    var trainingSessionId: String?
    let timestamp: Timestamp
    let type: NotificationType
    let uid: String

    var isFollowed: Bool? = false
    var trainingSession: TrainingSession?
    var user: User?
}

