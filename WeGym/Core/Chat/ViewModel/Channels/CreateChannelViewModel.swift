//
//  CreateChannelViewModel.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/26/23.
//

import UIKit

class CreateChannelViewModel: ObservableObject {
  let users: [User]
  @Published var didCreateChannel = false

  init(_ selectableUsers: [SelectableUser]) {
    self.users = selectableUsers.map({ $0.user })
  }

  func createChannel(name: String, image: UIImage?) async throws {
    guard let currentUser = UserService.shared.currentUser else { return }
    let currentUid = currentUser.id

    var uids = users.map({ $0.id })
    uids.append(currentUid)

    var data: [String: Any] = ["name": name,
                               "uids": uids,
                               "lastMessage": "\(currentUser.fullName ?? currentUser.username) created a channel"]
    if let image = image {
      let imageUrl = try await ImageUploader.uploadImage(image: image)
      data["imageUrl"] = imageUrl

      try await FirestoreConstants.ChannelsCollection.document().setData(data)
      self.didCreateChannel = true
    } else {
      try await FirestoreConstants.ChannelsCollection.document().setData(data)
      self.didCreateChannel = true
    }
  }
}
