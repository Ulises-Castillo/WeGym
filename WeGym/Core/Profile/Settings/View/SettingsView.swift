//
//  SettingsView.swift
//  WeGym
//
//  Created by Ulises Castillo on 11/3/23.
//

import SwiftUI

struct SettingsView: View {
  @Binding var selectedOption: SettingsItemModel?
  @Environment(\.dismiss) var dismiss

  var body: some View {
    List {
      ForEach(SettingsItemModel.allCases) { model in
        Button {
          selectedOption = model
          dismiss()
        } label: {
          SettingsRowView(model: model)
        }
      }
    }
    .listStyle(PlainListStyle())
    .padding(.vertical)
  }
}



struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView(selectedOption: .constant(nil))
  }
}
