//
//  NotificationsView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/19/23.
//

import SwiftUI

struct NotificationsView: View {
  @Environment(\.scenePhase) var scenePhase
  @EnvironmentObject var viewModel: NotificationsViewModel
  @Binding var shouldShowNotificationBadge: Bool
  @Binding var path: [WGNavigation]

  init(path: Binding<[WGNavigation]>, _ shouldShowNotificationBadge: Binding<Bool>) {
    self._path = path
    self._shouldShowNotificationBadge = shouldShowNotificationBadge
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
      .navigationDestination(for: WGNavigation.self) { screen in
        switch screen {
        case .profile(let user):
          ProfileView(user: user)
        case .trainingSessions:
          Text("Workouts")
        case .followers(let userId):
          UserListView(viewModel: SearchViewModel(config: SearchViewModelConfig.followers(userId)))
        case .following(let userId):
          UserListView(viewModel: SearchViewModel(config: SearchViewModelConfig.following(userId)))
        default:
          Text("Default")
        }
      }
      .onChange(of: scenePhase) { newPhase in
        if newPhase == .active {
          Task { try await viewModel.updateNotifications() }
        }
      }
      .refreshable {
        Task { try await viewModel.updateNotifications(force: true) }
      }
      .onAppear {
        Task { try await viewModel.updateNotifications() }
        shouldShowNotificationBadge = false
      }
      .overlay {
        if viewModel.isLoading {
          ProgressView()
        } else if viewModel.notifications.isEmpty {
          Text("No notifications yet")
            .foregroundColor(.secondary)
        }
      }
    }
  }
}
