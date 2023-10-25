//
//  ChatUserCell.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/24/23.
//

import SwiftUI

struct ChatUserCell: View {

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
          Text("venom")
            .font(.system(size: 14, weight: .semibold))

          Text("Eddie Brock")
            .font(.system(size: 15))
        }
        .foregroundColor(.black )

        Spacer()
      }
      .padding(.horizontal)

    }
    .padding(.top)
  }


}

#Preview {
  ChatUserCell()
}
