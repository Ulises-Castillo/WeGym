//
//  ProfileViewModel.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/19/23.
//

import SwiftUI

@MainActor
class ProfileViewModel: ObservableObject {
  @Published var user: User
  @Published var favoritePersonalRecords = [PersonalRecord]()
  @Published var isLoading = true

  init(user: User) {
    self.user = user
    fetchFavoritePersonalRecords(user.id)
  }

  func fetchFavoritePersonalRecords(_ userId: String) {
    Task { 
      let prs = try await PersonalRecordService.fetchFavoritePersonalRecords(userId: user.id)

      var sbd = [PersonalRecord]()

      for type in ["Squat", "Bench", "Deadlift"] {
        for pr in prs {
          if pr.type == type {
            sbd.append(pr)
            break
          }
        }
      }

      if sbd.count == 3 {
        favoritePersonalRecords = sbd
      } else {
        favoritePersonalRecords = prs
      }
      isLoading = false
    }
    print("**** favoritePersonalRecords: \(favoritePersonalRecords)")
  }

  func isFav(_ pr: PersonalRecord) -> Bool {
    return favoritePersonalRecords.map({ $0.id }).contains(pr.id)
  }

  func setFav(_ pr: PersonalRecord) {

    func updateDB() async throws {

      try await PersonalRecordService.uploadFavoritePersonalRecordIds(favoritePersonalRecords.map({$0.id}))
    }

    // remove if already fav and retrun
    if isFav(pr) {
      favoritePersonalRecords = favoritePersonalRecords.filter({ $0.id != pr.id })
    } else {
      //TODO: in future, should match reps also
      for (i, record) in favoritePersonalRecords.enumerated() {
        if record.type == pr.type {
          favoritePersonalRecords.remove(at: i)
          break
        }
      }

      if favoritePersonalRecords.count > 2 {
        favoritePersonalRecords.remove(at: 0)
      }

      favoritePersonalRecords.append(pr)
    }

    Task { try await updateDB() }
  }

  func loadUserData() {
    Task {
      async let stats = try await UserService.fetchUserStats(uid: user.id)
      self.user.stats = try await stats

      async let isFollowed = await checkIfUserIsFollowed()
      self.user.isFollowed = await isFollowed
    }
  }
}

// MARK: - Following

extension ProfileViewModel {
  func follow() {
    Task {
      try await UserService.follow(uid: user.id)
      user.isFollowed = true
      //            user.stats?.followers += 1
      NotificationCenter.default.post(name: .followingCountDidChange, object: nil)
      NotificationService.uploadNotification(toUid: user.id, type: .follow) //TODO: bring this in
    }
  }

  func unfollow() {
    Task {
      try await UserService.unfollow(uid: user.id)
      user.isFollowed = false
      NotificationCenter.default.post(name: .followingCountDidChange, object: nil)
      //            user.stats?.followers -= 1 //
    }
  }

  func checkIfUserIsFollowed() async -> Bool {
    guard !user.isCurrentUser else { return false }
    return await UserService.checkIfUserIsFollowed(uid: user.id)
  }
}

extension Notification.Name {
  static let followingCountDidChange = Notification.Name("followingCountDidChange")
}

