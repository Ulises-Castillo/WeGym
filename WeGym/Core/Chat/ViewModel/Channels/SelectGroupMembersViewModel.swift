//
//  SelectGroupMembersViewModel.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/25/23.
//

import Foundation

@MainActor
class SelectGroupMembersViewModel: ObservableObject {
  @Published var selectableUsers = [SelectableUser]()
  @Published var selectedUsers = [SelectableUser]()

  init() {
    Task { try await fetchUsers() }
  }

  // fetching users
  func fetchUsers() async throws {
    let query = FirestoreConstants.UserCollection
    guard let snapshot = try? await query.getDocuments() else { return }
    let users = snapshot.documents.compactMap({ try? $0.data(as: User.self) })
      .filter({ $0.id != UserService.shared.currentUser?.id })

    self.selectableUsers = users.map({ SelectableUser(user: $0) })
  }

  // select/deselect users
  func selectUser(_ user: SelectableUser, isSelected: Bool) {
    guard let index = selectableUsers.firstIndex(where: { $0.id == user.id }) else { return }

    selectableUsers[index].isSelected = isSelected

    if isSelected {
      selectedUsers.append(selectableUsers[index])
    } else {
      selectedUsers.removeAll(where: { $0.id == user.id })
    }
  }

  // filter users for search

}
