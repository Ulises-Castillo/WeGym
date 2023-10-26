//
//  ChannelCell.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/25/23.
//

import SwiftUI

struct ChannelCell: View {
  let channel: Channel

  var body: some View {
    NavigationLink(destination: ChannelChatView(channel)) {
      VStack {
        HStack {
          // image
          CircularProfileImageView(user: nil, size: .xSmall) //TODO: replace all KF images with this

          // message info
          VStack(alignment: .leading, spacing: 4) {

            Text(channel.name)
              .font(.system(size: 14, weight: .semibold))

            Text(channel.lastMessage)
              .font(.system(size: 15))
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
