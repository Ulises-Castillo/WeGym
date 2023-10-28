//
//  ChatTabView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/24/23.
//

import SwiftUI

struct ChatTabView: View {

  @State private var selectedIndex = 0

  var body: some View {
    NavigationView {
      TabView {
        ConversationsView()
          .onAppear { selectedIndex = 0 }
          .tabItem { Image(systemName: "bubble.left") }
          .tag(0)

        ChannelsView()
          .onAppear { selectedIndex = 1 }
          .tabItem { Image(systemName: "bubble.left.and.bubble.right") }
          .tag(1)

        SettingsView()
          .onAppear { selectedIndex = 2 }
          .tabItem { Image(systemName: "gear") }
          .tag(2)
      }
      .navigationTitle(tabTitle)
    }
  }

  var tabTitle: String {
    switch selectedIndex {
    case  0: return "Chats"
    case  1: return "Channels"
    case  2: return "Settings"
    default: return ""
    }
  }
}

#Preview {
  ChatTabView()
}
