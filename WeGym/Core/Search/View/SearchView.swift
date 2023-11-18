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
  @Binding var path: [WGNavigation]
  @EnvironmentObject var preloadedSearchViewModel: SearchViewModel
  
  var body: some View {
    NavigationStack(path: $path) {
      UserListView(viewModel: preloadedSearchViewModel)
        .navigationDestination(for: WGNavigation.self) { screen in
          switch screen {
          case .profile(let user):
            ProfileView(user: user)
          case .followers(let userId):
            UserListView(viewModel: SearchViewModel(config: SearchViewModelConfig.followers(userId)))
          case .following(let userId):
            UserListView(viewModel: SearchViewModel(config: SearchViewModelConfig.following(userId)))
          case .trainingSessions:
            Text("Workouts")
          default:
            Text("Default")
          }
        }
    }
    .onAppear {
      Task { await preloadedSearchViewModel.fetchUsers() }
    }
  }
}
