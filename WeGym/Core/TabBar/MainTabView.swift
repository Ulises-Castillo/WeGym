//
//  MainTabView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/12/23.
//

import SwiftUI

struct MainTabView: View {
  var body: some View {
    TabView {
      Text("Home")
        .tabItem {
          Image(systemName: "house")
        }
      
      SearchView()
        .tabItem {
          Image(systemName: "magnifyingglass")
        }
      
      Text("Notifications")
        .tabItem {
          Image(systemName: "person.bubble")
        }
      
      CurrentUserProfileView()
        .tabItem {
          Image(systemName: "person")
        }
    }
    .accentColor(.black)
  }
}

#Preview {
  MainTabView()
}
