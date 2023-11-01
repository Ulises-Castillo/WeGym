//
//  CommentService.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/23/23.
//

import Firebase
import FirebaseFirestoreSwift

class CommentService {

  let trainingSessionId: String

  private var firestoreListener: ListenerRegistration?

  init(trainingSessionId: String) {
    self.trainingSessionId = trainingSessionId
  }

  func uploadComment(_ comment: Comment) async throws { //TODO: fix bug where user cannot immediately comment on a newly created session, comment should be held until we have the session ID, then sent
    guard let commentData = try? Firestore.Encoder().encode(comment),
          !trainingSessionId.isEmpty else { return }

    try await FirestoreConstants
      .TrainingSessionsCollection
      .document(trainingSessionId)
      .collection("post-comments")
      .addDocument(data: commentData)
  }


  func observeComments(completion: @escaping([Comment]) -> Void) {
    guard !trainingSessionId.isEmpty else { return } // prevent empty ID (locally created session) CRASH

    let query = FirestoreConstants.TrainingSessionsCollection
      .document(trainingSessionId)
      .collection("post-comments")
      .order(by: "timestamp", descending: true)

    self.firestoreListener = query.addSnapshotListener { snapshot, _ in
      guard let changes = snapshot?.documentChanges.filter({ $0.type == .added }) else { return }
      var comments = changes.compactMap{ try? $0.document.data(as: Comment.self) }

      completion(comments)
    }
  }

  func removeListener() {
    self.firestoreListener?.remove()
    self.firestoreListener = nil
  }
}
