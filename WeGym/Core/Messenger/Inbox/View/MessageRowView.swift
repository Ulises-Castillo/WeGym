//
//  MessageRowView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/26/23.
//

import SwiftUI

struct MessageRowView: View {
  let message: Message
  @ObservedObject var viewModel: InboxViewModel
  @StateObject var userService = UserService.shared

  var body: some View {
    HStack(alignment: .top, spacing: 12) {

      HStack {
        if !message.read && !message.isFromCurrentUser {
          Circle()
            .fill(Color(.systemBlue))
            .frame(width: 6, height: 6, alignment: .leading)
        }

        let user = (message.user?.isCurrentUser ?? false) ? userService.currentUser : message.user
        CircularProfileImageView(user: user, size: .small)
      }

      VStack(alignment: .leading, spacing: 4) {
        if let user = (message.user?.isCurrentUser ?? false) ? userService.currentUser : message.user {
          Text(user.fullName ?? user.username)
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(.primary)
        }

        Text("\(message.isFromCurrentUser ? "You: \(message.text)" : message.text)")
          .font(.footnote)
          .foregroundColor(.gray)
          .lineLimit(2)
          .frame(maxWidth: UIScreen.main.bounds.width - 100, alignment: .leading)
      }

      HStack {
//        Text(message.timestamp.dateValue().timestampString()) //TODO: check this
        Text(message.timestamp.timestampString())

        Image(systemName: "chevron.right")
      }
      .font(.footnote)
      .foregroundColor(.gray)

    }
    .frame(maxHeight: 72)
    .swipeActions(content: {
      withAnimation(.spring()) {
        Button {
          Task { try await viewModel.deleteMessage(message) }
        } label: {
          Image(systemName: "trash")
        }
        .tint(Color(.systemRed))
      }
    })
  }
}

//struct InboxRowView_Previews: PreviewProvider { //TODO: add preview provider
//  static var previews: some View {
//    InboxRowView(message: dev.messages[0], viewModel: InboxViewModel())
//  }
//}
