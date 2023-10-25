//
//  ConversationCell.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/24/23.
//

import SwiftUI

struct ConversationCell: View {
  @ObservedObject var viewModel: MessageViewModel

  var body: some View {
    VStack {
      HStack {
        // image
        CircularProfileImageView(user: viewModel.user, size: .xSmall) //TODO: replace all KF images with this

        // message info
        VStack(alignment: .leading, spacing: 4) {
          if let user = viewModel.user {
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
    .onAppear {
      Task { try await viewModel.fetchUser() }
    }
  }
}
