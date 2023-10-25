//
//  MessageView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/24/23.
//

import SwiftUI

struct MessageView: View {
  var isFromCurrentUser: Bool
  var messageText: String

  var body: some View {
    HStack {
      if isFromCurrentUser {
        Spacer()

        Text(messageText)
          .padding(12)
          .background(Color(.systemBlue))
          .font(.system(size: 15))
          .clipShape(ChatBubble(isFromCurrentUser: true))
          .foregroundColor(.white)
          .padding(.leading, 100)
          .padding(.horizontal)
      } else {
        HStack(alignment: .bottom) {
          Image(systemName: "person")
            .resizable()
            .scaledToFill()
            .frame(width: 32, height: 32)
            .clipShape(Circle())

          Text(messageText)
            .padding(12)
            .background(Color(.systemGray5))
            .font(.system(size: 15))
            .clipShape(ChatBubble(isFromCurrentUser: false))
            .foregroundColor(.black)
        }
        .padding(.horizontal)
        .padding(.trailing, 80)

        Spacer()
      }
    }
  }
}

#Preview {
  MessageView(isFromCurrentUser: true, messageText: "Hey, how are you doing my brother?")
}
