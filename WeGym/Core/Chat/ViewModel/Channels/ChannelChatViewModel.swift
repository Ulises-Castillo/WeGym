//
//  ChannelChatViewModel.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/26/23.
//

import Firebase

class ChannelChatViewModel: ObservableObject {
  let channel: Channel
  @Published var messages = [Message]()

  init(_ channel: Channel) {
    self.channel = channel
    fetchChannelMessages()
  }

  func fetchChannelMessages() {
    
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
}
