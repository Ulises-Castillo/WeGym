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

    init(user: User) {
        self.user = user
        loadUserData()
    }

    func loadUserData() {
        Task {
//            async let stats = try await UserService.fetchUserStats(uid: user.id)
//            self.user.stats = try await stats

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
            NotificationService.uploadNotification(toUid: user.id, type: .follow) //TODO: bring this in
        }
    }

    func unfollow() {
        Task {
            try await UserService.unfollow(uid: user.id)
            user.isFollowed = false
//            user.stats?.followers -= 1 //
        }
    }

    func checkIfUserIsFollowed() async -> Bool {
        guard !user.isCurrentUser else { return false }
        return await UserService.checkIfUserIsFollowed(uid: user.id)
    }
}

