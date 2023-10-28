//
//  UserListView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/19/23.
//

import SwiftUI

struct UserListView: View {
    @StateObject var viewModel: SearchViewModel
    private let config: SearchViewModelConfig
    @State private var searchText = ""

    init(config: SearchViewModelConfig) {
        self.config = config
        self._viewModel = StateObject(wrappedValue: SearchViewModel(config: config))
    }

    var users: [User] {
        return searchText.isEmpty ? viewModel.users : viewModel.filteredUsers(searchText)
    }

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(users) { user in
                    NavigationLink(value: user) {
                        UserCell(user: user)
                            .padding(.leading)
                            .onAppear {
                                if user.id == users.last?.id ?? "" {
                                }
                            }
                    }
                }

            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer)
    }
}
