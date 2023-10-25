//
//  ChatView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/24/23.
//

import SwiftUI

struct ChatView: View {
  @State private var messageText = ""

  var body: some View {
    VStack {
      // messages
      ScrollView {
        VStack(alignment: .leading, spacing: 12) {
          ForEach((0...10), id: \.self) { _ in
            MessageView(isFromCurrentUser: true)
          }
        }
      }
      CustomInputView(text: $messageText, action: sendMessage)
    }
    .navigationTitle("venom")
    .navigationBarTitleDisplayMode(.inline)
    .padding(.vertical)
  }

  func sendMessage() {
    print("Send message \(messageText)")
    messageText = ""
  }
}

#Preview {
  ChatView()
}
