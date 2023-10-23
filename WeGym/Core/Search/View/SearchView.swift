//
//  SearchView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/12/23.
//

import SwiftUI

struct SearchView: View {
  @State var searchText = ""
  @State var inSearchMode = false
  @State var showingNotificationsSheet = false
  @Binding var shouldShowNotificationBadge: Bool
  @State var shouldShowNotificationBarItem: Bool
  

  init(isNewNotification: Binding<Bool>) {
    self._shouldShowNotificationBadge = isNewNotification
    self.shouldShowNotificationBarItem = isNewNotification.wrappedValue
  }

  var body: some View {
    NavigationStack {
      UserListView(config: .search)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: User.self) { user in
          ProfileView(user: user)
        }
        .toolbar {
          ToolbarItem(placement: .navigationBarTrailing) {
            Button {
              showingNotificationsSheet.toggle()
              shouldShowNotificationBarItem = false
            } label: {
              Image(systemName: shouldShowNotificationBarItem ? "bell.fill" : "bell")
                .foregroundColor(shouldShowNotificationBarItem ? Color(.systemBlue) : .primary)
                .padding(.horizontal, 9)
                .badge(10)
            }

          }
        }
        .sheet(isPresented: $showingNotificationsSheet) {
          NotificationsView()
            .foregroundColor(.primary)
        }
    }
    .onAppear {
      shouldShowNotificationBadge = false
    }
  }
}
