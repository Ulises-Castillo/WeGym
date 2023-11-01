//
//  NotificationHandler.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/23/23.
//

import SwiftUI

public class NotificationHandler: ObservableObject {
  // MARK: - Shared Instance
  /// The shared notification system for the process
  public static let shared = NotificationHandler()

  // MARK: - Properties
  /// Latest available notification
  @Published private(set) var latestNotification: UNNotificationResponse? = .none // default value

  // MARK: - Methods
  /// Handles the receiving of a UNNotificationResponse and propagates it to the app
  ///
  /// - Parameters:
  ///   - notification: The UNNotificationResponse to handle
  public func handle(notification: UNNotificationResponse) {
    self.latestNotification = notification
  }
}

struct NotificationViewModifier: ViewModifier {
  // MARK: - Private Properties
  private let onNotification: ([AnyHashable: Any]) -> Void

  // MARK: - Initializers
  init(onNotification: @escaping ([AnyHashable: Any]) -> Void, handler: NotificationHandler) {
    self.onNotification = onNotification
  }

  // MARK: - Body
  func body(content: Content) -> some View {
    content
      .onReceive(NotificationHandler.shared.$latestNotification) { notification in
        guard let notification else { return }
        let userInfo = notification.notification.request.content.userInfo
        onNotification(userInfo)
      }
  }
}

extension View {
  func onNotification(perform action: @escaping ([AnyHashable: Any]) -> Void) -> some View {
    modifier(NotificationViewModifier(onNotification: action, handler: NotificationHandler.shared))
  }
}
