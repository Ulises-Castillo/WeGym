//
//  MainTabView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/12/23.
//

import SwiftUI

struct MainTabView: View {
  let user: User
  @State private var selectedIndex = 1
  
  var body: some View {
    TabView(selection: $selectedIndex) {
      FeedView()
        .onAppear {
          selectedIndex = 0
        }
        .tabItem {
          Image(systemName: "house.fill")
        }.tag(0)
      
      TrainingSessionView(user: user)
        .onAppear {
          selectedIndex = 1
        }
        .tabItem {
          Image(systemName: "dumbbell")
        }.tag(1)
   
      UploadPostView(tabIndex: $selectedIndex)
        .onAppear {
          selectedIndex = 2
        }
        .tabItem {
          Image(systemName: "plus.square")
        }.tag(2)
      
      SearchView()
        .onAppear {
          selectedIndex = 3
        }
        .tabItem {
          Image(systemName: "magnifyingglass")
        }.tag(3)
      
      CurrentUserProfileView(user: user)
        .onAppear {
          selectedIndex = 4
        }
        .tabItem {
          Image(systemName: "person")
        }.tag(4)
    }
    .accentColor(.black)
  }
}

#Preview {
  MainTabView(user: User.MOCK_USERS[0])
}
