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
  
  var body: some View {
    TabView(selection: $selectedIndex) {
      TrainingSessionView(user: user)
        .onAppear {
          selectedIndex = 0
        }
        .tabItem {
          Image(systemName: "dumbbell")
        }.tag(0)
      
      SearchView()
        .onAppear {
          selectedIndex = 1
        }
        .tabItem {
          Image(systemName: "magnifyingglass")
        }.tag(1)
      
      CurrentUserProfileView(user: user)
        .onAppear {
          selectedIndex = 2
        }
        .tabItem {
          Image(systemName: "person")
        }.tag(2)
    }
    .accentColor(.black)
  }
}

#Preview {
  MainTabView(user: User.MOCK_USERS[0])
}
