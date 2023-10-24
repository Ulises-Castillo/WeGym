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

    Task { try await fetchComments() }
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
    
//    self.comments.insert(comment, at: 0)
    try await service.uploadComment(comment) //TODO: handle upload failure; match local data
    try await fetchComments()
  }


  func fetchComments() async throws {
    self.comments = try await service.fetchComments()
    try await fetchUserDataForComments()
  }

  private func fetchUserDataForComments() async throws {
    for i in 0..<comments.count {
      let comment = comments[i]
      let user = try await UserService.fetchUser(withUid: comment.commentOwnerUid)
      comments[i].user = user
    }
  }
}
