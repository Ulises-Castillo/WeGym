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

  var body: some View {
    NavigationStack {
      UserListView(config: .search)
        .navigationDestination(for: User.self) { user in
          ProfileView(user: user)
        }
    }
  }
}
