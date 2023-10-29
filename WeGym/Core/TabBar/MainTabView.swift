//
//  MainTabView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/12/23.
//

import SwiftUI

enum MessagesNavigation: Hashable {
  case chat(User)
}

struct MainTabView: View {
  enum Tab {
    case TrainingSessions, Messages, Notifications, Search, CurrentUserProfile
  }

  @State private var selectedTab: Tab = .TrainingSessions
  @State var shouldShowNotificationBadge = false

  init(user: User) {
    UITabBarItem.appearance().badgeColor = .systemBlue
  }

  @State private var messagesNavigationStack = [MessagesNavigation]()

  var body: some View {
    TabView(selection: tabSelection()) {
      TrainingSessionsView()
        .tabItem {
          Image(systemName: "dumbbell")
        }.tag(Tab.TrainingSessions)
      MessagesView(path: $messagesNavigationStack)
        .tabItem {
          Image(systemName: "envelope")
        }.tag(Tab.Messages)
      NotificationsView($shouldShowNotificationBadge)
        .tabItem {
          Image(systemName: "bell")
        }.tag(Tab.Notifications)
        .badge(shouldShowNotificationBadge ? "" : nil)
        .decreaseBadgeProminence()
      SearchView()
        .tabItem {
          Image(systemName: "magnifyingglass")
        }.tag(Tab.Search)
      CurrentUserProfileView()

        .tabItem {
          Image(systemName: "person")
        }.tag(Tab.CurrentUserProfile)
    }
    .accentColor(Color(.systemBlue))
    .onNotification { response in                                           //TODO: pass in userId to open correct chat
      if (response.notification.request.content.userInfo["notificationType"] as? String) == "new_direct_message" {
        selectedTab = .Messages
      } else {
        selectedTab = .Notifications
      }
    }
  }
}

extension MainTabView { //TODO: implement popToRoot/scrollToTop when tab current tapped

  private func tabSelection() -> Binding<Tab> {
    Binding { //this is the get block
      self.selectedTab
    } set: { tappedTab in
      print("*** selectedTab: \(selectedTab)")
      print("*** selectedTab: \(tappedTab)")
      if tappedTab == self.selectedTab {
        //User tapped on the currently active tab icon => Pop to root/Scroll to top
        switch tappedTab {
        case .TrainingSessions:
          break
        case .Messages:
          if messagesNavigationStack.isEmpty {
            // scroll to the top
          } else {
            // pop to root
            messagesNavigationStack = []
          }
        case .Notifications:
          break
        case .Search:
          break
        case .CurrentUserProfile:
          break
        }
      }
      //Set the tab to the user selected tab
      self.selectedTab = tappedTab
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
