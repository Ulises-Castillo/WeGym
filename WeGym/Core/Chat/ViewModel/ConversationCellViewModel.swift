//
//  ConversationCellViewModel.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/25/23.
//

import SwiftUI

class ConversationCellViewModel: ObservableObject {
  @Published var message: Message


  init(_ message: Message) {
    self.message = message
    Task { try await fetchUser() }
  }

  var currentUid: String {
    return UserService.shared.currentUser?.id ?? ""
  }

  var isFromCurrentUser: Bool {
    return message.fromId == currentUid
  }

  var profileImageUrl: URL? {
    guard let profileImageUrl = message.user?.profileImageUrl else { return nil }
    return URL(string: profileImageUrl)
  }

  var chatPartnerId: String {
    return message.fromId == currentUid ? message.toId : message.fromId
  }

  @MainActor
  func fetchUser() async throws {
    message.user = try await UserService.fetchUser(withUid: chatPartnerId)
  }
}
