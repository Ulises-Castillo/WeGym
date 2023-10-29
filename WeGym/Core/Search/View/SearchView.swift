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
  @Binding var path: [SearchNavigation]

  var body: some View {
    NavigationStack(path: $path) {
      UserListView(config: .search)
        .navigationDestination(for: SearchNavigation.self) { screen in
          switch screen {
          case .profile(let user):
            ProfileView(user: user)
          }
        }
    }
  }
}
