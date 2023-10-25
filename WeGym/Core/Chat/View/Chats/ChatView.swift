//
//  ChatView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/24/23.
//

import SwiftUI

struct ChatView: View {
  @State private var messageText = ""
  @ObservedObject var viewModel = ChatViewModel()
  private let user: User

  init(user: User) {
    self.user = user
  }

  var body: some View {
    VStack {
      // messages
      ScrollView {
        VStack(alignment: .leading, spacing: 12) {
          ForEach(viewModel.messages) { message in
            MessageView(isFromCurrentUser: message.isFromCurrentUser,
                        messageText: message.messageText)
          }
        }
      }
      CustomInputView(text: $messageText, action: sendMessage)
    }
    .navigationTitle(user.username)
    .navigationBarTitleDisplayMode(.inline)
    .padding(.vertical)
  }

  func sendMessage() {
    viewModel.sendMessage(messageText)
    messageText = ""
  }
}
