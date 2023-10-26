//
//  NewMessageViewModel.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/26/23.
//

import Foundation

class NewMessageViewModel: ObservableObject {
    @Published var users = [User]()
    @Published var searchText = ""

    var filteredUsers: [User] {
        if searchText.isEmpty {
            return users
        } else {
            return users.filter({
                $0.fullName?.lowercased().contains(searchText.lowercased()) ?? false
            })
        }
    }

    init() {
        Task { try await fetchUsers() }
    }

    @MainActor
    func fetchUsers() async throws {
        self.users = try await UserService.fetchUsers()
    }

}

