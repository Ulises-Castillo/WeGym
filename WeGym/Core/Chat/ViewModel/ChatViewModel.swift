//
//  ChatViewModel.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/24/23.
//

import Foundation

class ChatViewModel: ObservableObject {

  @Published var messages = [Message]()

  init() {
    messages = mockMessages
  }

  var mockMessages: [Message] {
    [
      .init(isFromCurrentUser: true, messageText: "Hey what's up man"),
      .init(isFromCurrentUser: false, messageText: "Not much how are you"),
      .init(isFromCurrentUser: true, messageText: "I'm doing fine. having fun building WeGym!"),
      .init(isFromCurrentUser: true, messageText: "Are you learning alot?"),
      .init(isFromCurrentUser: false, messageText: "Yeah I am I love this course"),
      .init(isFromCurrentUser: true, messageText: "That awesome, im glad I bought it"),
      .init(isFromCurrentUser: false, messageText: "That's awesome, im glad I bought it"),
      .init(isFromCurrentUser: false, messageText: "Talk to you later!"),
      .init(isFromCurrentUser: true, messageText: "Hey what's up man"),
      .init(isFromCurrentUser: true, messageText: "Hey what's up man"),
    ]
  }

  func sendMessage(_ messageText: String) {
    let message = Message(isFromCurrentUser: true, messageText: messageText)
    messages.append(message)
  }
}
