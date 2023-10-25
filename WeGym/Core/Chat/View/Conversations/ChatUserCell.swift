//
//  ChatUserCell.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/24/23.
//

import SwiftUI

struct ChatUserCell: View {
  let user: User

  var body: some View {
    VStack {
      HStack {
        // image
        CircularProfileImageView(user: user, size: .xSmall)

        // message info
        VStack(alignment: .leading, spacing: 4) {
          Text(user.username)
            .font(.system(size: 14, weight: .semibold))

          if let fullName = user.fullName {
            Text(fullName)
              .font(.system(size: 15))
          }
        }
        .foregroundColor(.black )

        Spacer()
      }
      .padding(.horizontal)

    }
    .padding(.top)
  }


}

