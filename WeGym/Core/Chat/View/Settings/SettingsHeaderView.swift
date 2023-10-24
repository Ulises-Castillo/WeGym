//
//  SettingsHeaderView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/24/23.
//

import SwiftUI

struct SettingsHeaderView: View {
  var body: some View {
    HStack {
      Image(systemName: "person")
        .resizable()
        .scaledToFill()
        .frame(width: 64, height: 64)
        .clipShape(Circle())
        .padding(.leading)

      VStack(alignment: .leading, spacing: 4) {
        Text("Eddie Brock")
          .font(.system(size: 18))
          .foregroundColor(.black)

        Text("Available")
          .foregroundColor(.gray)
          .font(.system(size: 14))
      }

      Spacer()
    }
    .frame(height: 80)
    .background(.white)
  }
}

#Preview {
    SettingsHeaderView()
}
