//
//  NotificationsView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/19/23.
//

import SwiftUI

struct NotificationsView: View {
  @StateObject var viewModel: NotificationsViewModel
  @Binding var shouldShowNotificationBadge: Bool
  @Binding var path: [NotificationsNavigation]

  init(path: Binding<[NotificationsNavigation]>, _ shouldShowNotificationBadge: Binding<Bool>) {
    self._path = path
    self._shouldShowNotificationBadge = shouldShowNotificationBadge
    self._viewModel = StateObject(wrappedValue: NotificationsViewModel())
  }

  var body: some View {
    NavigationStack(path: $path) {
      ScrollView {
        LazyVStack(spacing: 20) {
          ForEach($viewModel.notifications) { notification in
            NotificationCell(notification: notification)
              .padding(.top)
              .onAppear {
                if notification.id == viewModel.notifications.last?.id ?? "" {
                  print("DEBUG: paginate here..")
                }
              }
          }
        }
        .navigationTitle("Notifications")
      }
      .navigationDestination(for: NotificationsNavigation.self) { screen in
        switch screen {
        case .profile(let user):
          ProfileView(user: user)
        }
      }
      .onAppear {
        shouldShowNotificationBadge = false
      }
      .overlay {
        if viewModel.isLoading {
          ProgressView()
        }
      }
    }
  }
}
