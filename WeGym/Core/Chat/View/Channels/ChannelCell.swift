//
//  ChannelCell.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/25/23.
//

import SwiftUI

struct ChannelCell: View {
  var body: some View {
    NavigationLink(destination: Text("Channel chat view")) {
      VStack {
        HStack {
          // image
          CircularProfileImageView(user: nil, size: .xSmall) //TODO: replace all KF images with this

          // message info
          VStack(alignment: .leading, spacing: 4) {

            Text("Gotham City")
              .font(.system(size: 14, weight: .semibold))

            Text("Bruce Wayne: I'm here to save Gotham")
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

#Preview {
  ChannelCell()
}
