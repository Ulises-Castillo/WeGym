//
//  SettingsCell.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/24/23.
//

import SwiftUI

struct SettingsCell: View {

  let viewModel: SettingsCellViewModel

  var body: some View {
    VStack {
      HStack {
        // image
        Image(systemName: viewModel.imageName)
          .resizable()
          .scaledToFit()
          .frame(width: 22, height: 22)
          .padding(6)
          .background(viewModel.backgroundColor)
          .foregroundColor(.white)
          .cornerRadius(6)
        // name
        Text(viewModel.title)
          .font(.system(size: 15))

        Spacer()

        // arrow
        Image(systemName: "chevron.right")
          .foregroundColor(.secondary)
      }
      .padding([.top, .horizontal])

      Divider()
        .padding(.leading)
    }
    .background(.white)
  }
}

