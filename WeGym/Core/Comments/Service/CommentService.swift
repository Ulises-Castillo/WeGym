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

  func uploadComment(_ comment: Comment) async throws {
    guard let commentData = try? Firestore.Encoder().encode(comment) else { return }

    try await FirestoreConstants
      .TrainingSessionsCollection
      .document(trainingSessionId)
      .collection("post-comments")
      .addDocument(data: commentData)
  }

  func fetchComments() async throws -> [Comment] {
    let snapshot = try await FirestoreConstants
      .TrainingSessionsCollection
      .document(trainingSessionId)
      .collection("post-comments")
      .order(by: "timestamp", descending: true) //TODO: can this be used to sort training sessions?
      .getDocuments()

    return snapshot.documents.compactMap({ try? $0.data(as: Comment.self) })
  }
}
