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
  
  init() {
    Task { try await fetchTrainingSessions() }
  }

  @MainActor
  func fetchTrainingSessions() async throws {
    trainingSessions = try await TrainingSessionService.fetchTrainingSessions(forDay: day)
    print("Training Sessions: \(trainingSessions)")
  }
}
