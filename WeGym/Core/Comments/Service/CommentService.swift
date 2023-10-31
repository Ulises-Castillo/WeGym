//
//  CommentService.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/23/23.
//

import Firebase
import FirebaseFirestoreSwift

struct CommentService {

  let trainingSessionId: String

  func uploadComment(_ comment: Comment) async throws { //TODO: fix bug where user cannot immediately comment on a newly created session, comment should be held until we have the session ID, then sent
    guard let commentData = try? Firestore.Encoder().encode(comment),
          !trainingSessionId.isEmpty else { return }

    try await FirestoreConstants
      .TrainingSessionsCollection
      .document(trainingSessionId)
      .collection("post-comments")
      .addDocument(data: commentData)
  }

  func fetchComments() async throws -> [Comment] {
    guard !trainingSessionId.isEmpty else { return [] } //FIXED CRASH: if user created new training session and immediately taps the comment button there is no sessionID yet from backend.

    let snapshot = try await FirestoreConstants
      .TrainingSessionsCollection
      .document(trainingSessionId)
      .collection("post-comments")
      .order(by: "timestamp", descending: true) //TODO: can this be used to sort training sessions?
      .getDocuments()

    return snapshot.documents.compactMap({ try? $0.data(as: Comment.self) })
  }
}
