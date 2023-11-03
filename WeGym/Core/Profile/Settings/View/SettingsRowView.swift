//
//  SettingsRowView.swift
//  WeGym
//
//  Created by Ulises Castillo on 11/3/23.
//

import SwiftUI

struct SettingsRowView: View {
  let model: SettingsItemModel

  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: model.imageName)
        .imageScale(.medium)
        .foregroundColor(model == .logout ? .red : .primary)

      Text(model.title)
        .font(.subheadline)
        .foregroundColor(model == .logout ? .red : .primary)
    }
  }
}

struct SettingsRowView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsRowView(model: .saved)
  }
}
