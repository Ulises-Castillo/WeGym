//
//  MessageViewModel.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/25/23.
//

import Foundation

struct MessageViewModel {
  let message: Message

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
}
