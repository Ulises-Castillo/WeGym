//
//  MessageViewModel.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/25/23.
//

import Foundation

class MessageViewModel: ObservableObject {
  @Published var user: User?
  let message: Message

  init(_ message: Message) {
    self.message = message
//    Task { try await fetchUser() }
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

//  var profile

  @MainActor
  func fetchUser() async throws {
    user = try await UserService.fetchUser(withUid: chatPartnerId)
  }
}
