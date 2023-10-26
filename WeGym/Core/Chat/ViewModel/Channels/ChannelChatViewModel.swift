//
//  ChannelChatViewModel.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/26/23.
//

import Firebase

@MainActor
class ChannelChatViewModel: ObservableObject {
  let channel: Channel
  @Published var messages = [Message]()

  init(_ channel: Channel) {
    self.channel = channel
    fetchChannelMessages()
  }

  func fetchChannelMessages() { //TODO: use async await across the app
    guard let currentUid = UserService.shared.currentUser?.id else { return }
    guard let channelId = channel.id else { return }

    let query = FirestoreConstants
      .ChannelsCollection
      .document(channelId)
      .collection("messages")
      .order(by: "timestamp", descending: false)

    query.addSnapshotListener { snapshot, _ in

      guard let changes = snapshot?.documentChanges.filter({ $0.type == .added }) else { return }

      let tmpMessages = changes.compactMap{ try? $0.document.data(as: Message.self) }

      for (index, message) in tmpMessages.enumerated() where message.fromId != currentUid {
        self.fetchUser(withUid: message.fromId) { user in
          self.messages[index].user = user
        }
      }
      self.messages.append(contentsOf: tmpMessages)
    }
  }

  func sendChannelMessage(messageText: String) {
    guard let currentUser = UserService.shared.currentUser else { return }
    let currentUid = currentUser.id
    guard let channelId = channel.id else { return }

    let data: [String: Any] = [
      "text": messageText,
      "fromId": currentUid,
      "toId": channelId,
      "read": false,
      "timestamp": Timestamp(date: Date())
    ]

    FirestoreConstants.ChannelsCollection.document(channelId)
      .collection("messages").document().setData(data)

    FirestoreConstants.ChannelsCollection.document(channelId)
      .updateData(["lastMessage": "\(currentUser.username): \(messageText)"])
  }

  private func fetchUser(withUid uid: String, completion: @escaping(User) -> Void) { //TODO: user UserService
    FirestoreConstants.UserCollection.document(uid).getDocument { snapshot, _ in
      guard let user = try? snapshot?.data(as: User.self) else { return }
      print("DEBUG: User is \(user.username)")
      completion(user)
    }
  }
}
