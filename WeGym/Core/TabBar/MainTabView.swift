//
//  MainTabView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/12/23.
//

import SwiftUI

struct MainTabView: View {
  let user: User
  @State private var selectedIndex = 0
  @StateObject var notificationManager = NotificationManager()

  var body: some View {
    TabView(selection: $selectedIndex) {
      TrainingSessionView(user: user)
        .onAppear {
          selectedIndex = 0
          if !notificationManager.hasPermission {
            Task { await notificationManager.request() }
          }
        }
        .tabItem {
          Image(systemName: "dumbbell")
        }.tag(0)

      SearchView()
        .onAppear {
          selectedIndex = 1
        }
        .tabItem {
          Image(systemName: "magnifyingglass")  //TODO: Consider replacing this with WeGym logo (arms)
        }.tag(1)                                // actually makes sense considering you add gym bros here
                                                // (arms clutching each other) + notifications there
      CurrentUserProfileView(user: user)        // so its not just a search tab. Would also be cool to
        .onAppear {                             // have the logo centered at the bottom, always visible.
          selectedIndex = 2
        }
        .tabItem {
          Image(systemName: "person")
        }.tag(2)
    }
    .accentColor(.primary)
    .task { await notificationManager.getAuthStatus() }
  }
}

#Preview {
  MainTabView(user: User.MOCK_USERS[0])
}
