//
//  FeedCellViewModel.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/23/23.
//

import Foundation

@MainActor
class TrainingSessionCellViewModel: ObservableObject {
  @Published var trainingSession: TrainingSession
  @Published var commentsCount = 0

  init(trainingSession: TrainingSession) {
    self.trainingSession = trainingSession
    Task { try await checkIfUserLikedTrainingSession() }
    Task { commentsCount = try await CommentService.commentsCount(id:trainingSession.id) }
  }

  func like() async throws {
    do {
      let trainingSessionCopy = trainingSession
      trainingSession.didLike = true
      trainingSession.likes += 1
      try await TrainingSessionService.likeTrainingSession(trainingSessionCopy)
    } catch {
      trainingSession.didLike = false
      trainingSession.likes -= 1
    }
  }

  func unlike() async throws {
    do {
      let trainingSessionCopy = trainingSession
      trainingSession.didLike = false
      trainingSession.likes -= 1
      try await TrainingSessionService.unlikeTrainingSession(trainingSessionCopy)
    } catch {
      trainingSession.didLike = true
      trainingSession.likes += 1
    }
  }

  func checkIfUserLikedTrainingSession() async throws {
    guard !trainingSession.id.isEmpty else { return } // required to prevent CRASH on new session (no id yet) 
    self.trainingSession.didLike = try await TrainingSessionService.checkIfUserLikedTrainingSession(trainingSession)
  }
}
