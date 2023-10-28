//
//  ConversationCell.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/24/23.
//

import SwiftUI

struct ConversationCell: View {
  @ObservedObject var viewModel: ConversationCellViewModel

  var body: some View {
    if let user = viewModel.message.user {
      NavigationLink(destination: ChatView(user: user)) {
        VStack {
          HStack {
            // image
            CircularProfileImageView(user: viewModel.message.user, size: .xSmall) //TODO: replace all KF images with this

            // message info
            VStack(alignment: .leading, spacing: 4) {
              if let user = viewModel.message.user {
                Text(user.fullName ?? user.username)
                  .font(.system(size: 14, weight: .semibold))
              }

              Text(viewModel.message.text)
                .font(.system(size: 14))
            }.foregroundColor(.black)
            Spacer()
          }
          .padding(.horizontal)

          Divider()
        }
        .padding(.top)
      }
    }
  }
}
