//
//  TrainingSessionViewModel.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/17/23.
//

import Foundation


class TrainingSessionViewModel: ObservableObject {
  
  @Published var trainingSessions = [TrainingSession]()
  public var day = Date.now // changing this day and re-fetching will be the sauce
  
  //TODO: consider making this an array such that the user can have multiple training sessions scheduled in the same day (big for martial arts)
  @Published var currentUserTrainingSesssion: TrainingSession?
  
  init() {
    Task { try await fetchTrainingSessions() }
  }
  
  @MainActor
  func fetchTrainingSessions() async throws {
    trainingSessions = try await TrainingSessionService.fetchTrainingSessions(forDay: day)
    
    for i in 0..<trainingSessions.count {
      let session = trainingSessions[i]
      if let user = session.user, user.isCurrentUser {
        currentUserTrainingSesssion = session
        trainingSessions.remove(at: i)
        break
      }
    }
  }
}
