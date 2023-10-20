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
  @Published var shouldShowTime = true

  var isFirstFetch = true
  var isFetching = false // prevent redundant calls
  
  init() {
    Task { try await fetchTrainingSessions() }
  }
  
  func relaiveDay() -> String {
    let relativeDateFormatter = DateFormatter()
    relativeDateFormatter.timeStyle = .none
    relativeDateFormatter.dateStyle = .medium
    relativeDateFormatter.locale = Locale(identifier: "en_GB")
    relativeDateFormatter.doesRelativeDateFormatting = true
    
    let inputFormatter = DateFormatter()
    inputFormatter.dateFormat = "yyyy-MM-dd"

    return relativeDateFormatter.string(from: day)
  }
  
  @MainActor
  func fetchTrainingSessions() async throws {
    isFirstFetch = false
    guard !isFetching else { return }
    isFetching = true
    
    trainingSessions = try await TrainingSessionService.fetchTrainingSessions(forDay: day)
    
    var isFound = false
    
    for i in 0..<trainingSessions.count {
      let session = trainingSessions[i]
      if let user = session.user, user.isCurrentUser {
        currentUserTrainingSesssion = session
        trainingSessions.remove(at: i)
        isFound = true
        break
      }
    }
    if !isFound {
      currentUserTrainingSesssion = nil
    }
    
    isFetching = false
  }
}
