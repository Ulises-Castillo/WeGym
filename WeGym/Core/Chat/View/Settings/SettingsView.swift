//
//  SettingsView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/24/23.
//

import SwiftUI

struct SettingsView: View {
  var body: some View {
    ZStack {
      Color(.systemGroupedBackground)
        .ignoresSafeArea()

      VStack(spacing: 32) {
        NavigationLink(destination: EditProfileView(), label: { SettingsHeaderView() })

        VStack(spacing: 1) {
          ForEach(SettingsCellViewModel.allCases, id: \.self) { viewModel in
            SettingsCell(viewModel: viewModel)
          }
        }

        Button {
          print("handle log out ... ")
        } label: {
          Text("Log Out")
            .foregroundColor(.red)
            .font(.system(size: 16, weight: .semibold))
            .frame(width: UIScreen.main.bounds.width, height: 50)
            .background(.white)
        }

        Spacer()
      }
    }
  }
}

#Preview {
  SettingsView()
}

