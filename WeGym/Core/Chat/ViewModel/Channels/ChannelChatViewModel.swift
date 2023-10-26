//
//  ChannelChatViewModel.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/26/23.
//

import Foundation

class ChannelChatViewModel: ObservableObject {
  let channel: Channel
  @Published var messages = [Message]()

  init(_ channel: Channel) {
    self.channel = channel
    fetchChannelMessages()
  }

  func fetchChannelMessages() {

  }

  func sendChannelMessage() {

  }
}
