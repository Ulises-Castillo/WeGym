//
//  CommentsViewModel.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/23/23.
//

import Firebase

@MainActor
class CommentsViewModel: ObservableObject {
  @Published var comments = [Comment]()

  private let trainingSession: TrainingSession
  private let service: CommentService

  init(trainingSession: TrainingSession) {
    self.trainingSession = trainingSession
    self.service = CommentService(trainingSessionId: trainingSession.id)
    observeComments()
  }

  func observeComments() {
    service.observeComments { [weak self] comments in
      guard let self = self else { return }
      var comments = comments
      Task {
        for i in 0..<comments.count {
          comments[i].user = try await UserService.fetchUser(withUid: comments[i].commentOwnerUid)
        }
        self.comments.insert(contentsOf: comments, at: 0)
      }
    }
  }

  func uploadComment(commentText: String) async throws {
    guard let uid = Auth.auth().currentUser?.uid else { return }

    let comment = Comment(
      trainingSessionOwnerUid: trainingSession.ownerUid,
      commentText: commentText,
      trainingSessionId: trainingSession.id,
      timestamp: Timestamp(),
      commentOwnerUid: uid
    )

    try await service.uploadComment(comment) //TODO: handle upload failure; match local data
    NotificationService.uploadNotification(toUid: trainingSession.ownerUid, type: .comment, trainingSession: trainingSession)
  }

  private func fetchUserDataForComments() async throws {
    for i in 0..<comments.count {
      let comment = comments[i]
      let user = try await UserService.fetchUser(withUid: comment.commentOwnerUid)
      comments[i].user = user
    }
  }

  func removeChatListener() {
    service.removeListener()
  }
}
