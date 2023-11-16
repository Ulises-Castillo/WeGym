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
  @EnvironmentObject var preloadedSearchViewModel: SearchViewModel

  var body: some View {
    NavigationStack(path: $path) {
      UserListView(viewModel: preloadedSearchViewModel)
        .navigationDestination(for: SearchNavigation.self) { screen in
          switch screen {
          case .profile(let user):
            ProfileView(user: user)
          }
        }
    }
    .onAppear {
      Task { await preloadedSearchViewModel.fetchUsers() }
    }
  }
}
