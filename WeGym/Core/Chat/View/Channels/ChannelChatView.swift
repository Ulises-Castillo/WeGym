//
//  ChannelChatView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/26/23.
//

import SwiftUI

struct ChannelChatView: View {
  @ObservedObject var viewModel: ChannelChatViewModel
  @State private var messageText = ""

  init(_ channel: Channel) {
    self.viewModel = ChannelChatViewModel(channel)
  }

  var body: some View {
    VStack {
      // messages
      ScrollView {
        VStack(alignment: .leading, spacing: 12) {
          ForEach(viewModel.messages) { message in
            MessageView(viewModel: MessageViewModel(message))
          }
        }
      }
      CustomInputView(text: $messageText, action: sendMessage)
    }
    .navigationTitle(viewModel.channel.name)
    .navigationBarTitleDisplayMode(.inline)
    .padding(.vertical)
  }

  func sendMessage() {
    viewModel.sendChannelMessage()
    messageText = ""
  }
}
