//
//  MainTabView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/12/23.
//

import SwiftUI

enum Tab {
  case TrainingSessions, Messages, Notifications, Search, CurrentUserProfile
}

class AppNavigation: ObservableObject {
  static let shared = AppNavigation()
  
  @Published var selectedTab: Tab = .TrainingSessions

  @Published var trainingSessionsNavigationStack = [TrainingSessionsNavigation]()
  @Published var messagesNavigationStack = [MessagesNavigation]()
  @Published var notificationsNavigationStack = [NotificationsNavigation]()
  @Published var searchNavigationStack = [SearchNavigation]()
}

enum TrainingSessionsNavigation: Hashable {
  case profile(User)
  case chat(User)
}

enum MessagesNavigation: Hashable {
  case chat(User)
}

enum NotificationsNavigation: Hashable {
  case profile(User)
}

enum SearchNavigation: Hashable {
  case profile(User)
}

struct MainTabView: View {

  @State var shouldShowNotificationBadge = false

  init(user: User) {
    UITabBarItem.appearance().badgeColor = .systemBlue
  }

  @State private var showToday = false
  @StateObject var appNav = AppNavigation.shared

  var body: some View {
    TabView(selection: tabSelection()) {
      TrainingSessionsView(path: $appNav.trainingSessionsNavigationStack, showToday: $showToday)
        .tabItem {
          Image(systemName: "dumbbell")
        }.tag(Tab.TrainingSessions)
      MessagesView(path: $appNav.messagesNavigationStack)
        .tabItem {
          Image(systemName: "envelope")
        }.tag(Tab.Messages)
      NotificationsView(path: $appNav.notificationsNavigationStack, $shouldShowNotificationBadge)
        .tabItem {
          Image(systemName: "bell")
        }.tag(Tab.Notifications)
        .badge(shouldShowNotificationBadge ? "" : nil)
        .decreaseBadgeProminence()
      SearchView(path: $appNav.searchNavigationStack)
        .tabItem {
          Image(systemName: "magnifyingglass")
        }.tag(Tab.Search)
      CurrentUserProfileView()

        .tabItem {
          Image(systemName: "person")
        }.tag(Tab.CurrentUserProfile)
    }
    .accentColor(Color(.systemBlue))
    .onNotification { userInfo in                                           //TODO: move verbose logic to extension + enum to handle notification types
      if (userInfo["notificationType"] as? String) == "new_direct_message" { //TODO: should just be passing what is needed // decode push notifications into enums / objects (make models?)
        appNav.selectedTab = .Messages

        if let fromId = userInfo["fromId"] as? String {
          Task {
            let user = try await UserService.fetchUser(withUid: fromId)
            appNav.messagesNavigationStack.removeAll()
            appNav.messagesNavigationStack.append(.chat(user))
          }
        }
      } else if (userInfo["notificationType"] as? String) == "new_training_session_like" {
        appNav.selectedTab = .TrainingSessions
        appNav.trainingSessionsNavigationStack.removeAll()
      } else {
        appNav.selectedTab = .Notifications
      }
    }
  }
}

extension MainTabView { //TODO: implement popToRoot/scrollToTop when tab current tapped

  private func tabSelection() -> Binding<Tab> {
    Binding { //this is the get block
      appNav.selectedTab
    } set: { tappedTab in
      print("*** selectedTab: \(appNav.selectedTab)")
      print("*** selectedTab: \(tappedTab)")
      if tappedTab == appNav.selectedTab {
        //User tapped on the currently active tab icon => Pop to root/Scroll to top
        switch tappedTab {
        case .TrainingSessions:
          if appNav.trainingSessionsNavigationStack.isEmpty {
            // scroll to the top //TODO: implement for all tabs

            // if already at the top
            // show today's training sessions
            showToday = true
          } else {
            // pop to root
            appNav.trainingSessionsNavigationStack = []
          }
        case .Messages:
          if appNav.messagesNavigationStack.isEmpty {
            // scroll to the top
          } else {
            // pop to root
            appNav.messagesNavigationStack = []
          }
        case .Notifications:
          if appNav.notificationsNavigationStack.isEmpty {
          } else {
            appNav.notificationsNavigationStack = []
          }
        case .Search:
          if appNav.searchNavigationStack.isEmpty {
          } else {
            appNav.searchNavigationStack = []
          }
        case .CurrentUserProfile:
          break
        }
      }
      //Set the tab to the user selected tab
      appNav.selectedTab = tappedTab
    }
  }
}

#Preview {
  MainTabView(user: User.MOCK_USERS_2[0])
}

//TODO: Consider replacing "bell" image with WeGym logo (arms)
// actually makes sense considering you add gym bros here
// (arms clutching each other) + notifications there
// so its not just a search tab. Would also be cool to
// have the logo centered at the bottom, always visible.
