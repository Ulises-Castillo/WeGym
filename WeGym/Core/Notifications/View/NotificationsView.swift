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

  init(_ shouldShowNotificationBadge: Binding<Bool>) {
    self._shouldShowNotificationBadge = shouldShowNotificationBadge
    self._viewModel = StateObject(wrappedValue: NotificationsViewModel())
  }

  var body: some View {
    NavigationStack {
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
