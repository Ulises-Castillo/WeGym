//
//  ConversationCell.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/24/23.
//

import SwiftUI

struct ConversationCell: View {
  let viewModel: MessageViewModel

  var body: some View {
    VStack {
      HStack {
        // image
        Image(systemName: "person")//TODO: non-sytem image here
          .resizable()
          .scaledToFill()
          .frame(width: 48, height: 48)
          .clipShape(Circle())

        // message info
        VStack(alignment: .leading, spacing: 4) {
          Text("Eddie Brock")
            .font(.system(size: 14, weight: .semibold))

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
