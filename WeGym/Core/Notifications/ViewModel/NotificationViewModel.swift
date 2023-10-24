//
//  NotificationViewModel.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/19/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

@MainActor
class NotificationsViewModel: ObservableObject {
  @Published var notifications = [Notification2]()
  @Published var isLoading = false
  @Published var isNewNotification = false

  init() {
    Task { try await updateNotifications() }
  }

  func updateNotifications() async throws {
    isLoading = true
    notifications = await NotificationService.fetchNotifications()
    isLoading = false

    await withThrowingTaskGroup(of: Void.self, body: { group in
      for notification in notifications {
        group.addTask { try await self.updateNotificationMetadata(notification: notification) }
      }
    })
  }

  private func updateNotificationMetadata(notification: Notification2) async throws {
    guard let indexOfNotification = notifications.firstIndex(where: { $0.id == notification.id }) else { return }

    async let notificationUser = try await UserService.fetchUser(withUid: notification.uid)
    self.notifications[indexOfNotification].user = try await notificationUser

    if notification.type == .follow {
      async let isFollowed = await UserService.checkIfUserIsFollowed(uid: notification.uid)
      self.notifications[indexOfNotification].isFollowed = await isFollowed
    }

    if let postId = notification.postId {
      async let postSnapshot = await FirestoreConstants.PostsCollection.document(postId).getDocument()
      self.notifications[indexOfNotification].post = try? await postSnapshot.data(as: Post.self)
    }
  }
}

