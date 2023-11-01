//
//  Comment.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/23/23.
//

import Firebase
import FirebaseFirestoreSwift

struct Comment: Identifiable, Codable, Hashable {

  @DocumentID var commentID: String?
  let trainingSessionOwnerUid: String
  let commentText: String
  let trainingSessionId: String
  let timestamp: Timestamp
  let commentOwnerUid: String

  var user: User?

  var id: String {
    return commentID ?? NSUUID().uuidString
  }

  
}
