//
//  MainTabView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/12/23.
//

import SwiftUI

struct MainTabView: View {
  @State private var selectedIndex = 0
  @State var shouldShowNotificationBadge = false

  init(user: User) {
    UITabBarItem.appearance().badgeColor = .systemBlue
  }

  var body: some View {
    TabView(selection: $selectedIndex) {
      TrainingSessionView()
        .onAppear {
          selectedIndex = 0
        }
        .tabItem {
          Image(systemName: "dumbbell")
        }.tag(0)
      InboxView()
        .onAppear {
          selectedIndex = 1
        }
        .tabItem {
          Image(systemName: "envelope")
        }.tag(1)
      NotificationsView($shouldShowNotificationBadge)
        .onAppear {
          selectedIndex = 2
        }
        .tabItem {
          Image(systemName: "bell")
        }.tag(2)
        .badge(shouldShowNotificationBadge ? "" : nil)
        .decreaseBadgeProminence()
      SearchView()
        .onAppear {
          selectedIndex = 3
        }
        .tabItem {
          Image(systemName: "magnifyingglass")        //TODO: Consider replacing this with WeGym logo (arms)
        }.tag(3)                                      // actually makes sense considering you add gym bros here
                                                      // (arms clutching each other) + notifications there
      CurrentUserProfileView()                        // so its not just a search tab. Would also be cool to
        .onAppear {                                   // have the logo centered at the bottom, always visible.
          selectedIndex = 4
        }
        .tabItem {
          Image(systemName: "person")
        }.tag(4)
    }
    .accentColor(Color(.systemBlue))
    .onNotification { notification in
      shouldShowNotificationBadge = true
    }
  }
}

#Preview {
  MainTabView(user: User.MOCK_USERS_2[0])
}
