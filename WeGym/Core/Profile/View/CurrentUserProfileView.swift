//
//  CurrentUserProfileView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/13/23.
//

import SwiftUI

struct CurrentUserProfileView: View {

  @EnvironmentObject var viewModel: ProfileViewModel
  @State private var showSettingsSheet = false
  @State private var selectedSettingsOption: SettingsItemModel?
  @State private var showDetail = false
  @Binding var path: [CurrentUserProfileNavigation]

  init(path: Binding<[CurrentUserProfileNavigation]>) {
    self._path = path
  }

  var body: some View {
    NavigationStack(path: $path) {
      ScrollView {
        VStack(spacing: 24) {
          ProfileHeaderView(viewModel: viewModel)

//          PostGridView(config: .profile(UserService.shared.currentUser!))
        }
      }
      .navigationTitle(UserService.shared.currentUser?.username ?? "")
      .navigationBarTitleDisplayMode(.inline)
      .navigationDestination(for: CurrentUserProfileNavigation.self) { screen in
        switch screen {
        case .personalRecords:
          PersonalRecordsView()
        default:
          Text(selectedSettingsOption?.title ?? "")
        }
      }
      .sheet(isPresented: $showSettingsSheet) {
        SettingsView(selectedOption: $selectedSettingsOption, path: $path)
          .presentationDetents([.height(CGFloat(SettingsItemModel.allCases.count * 56))])
          .presentationDragIndicator(.visible)
      }

      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            selectedSettingsOption = nil
            showSettingsSheet.toggle()
          } label: {
            Image(systemName: "line.3.horizontal")
              .foregroundColor(.primary)
          }
        }
      }
      .onChange(of: selectedSettingsOption) { newValue in
        guard let option = newValue else { return }

        if option != .logout {
          self.showDetail.toggle()
        } else {
          AuthService.shared.signOut()
        }
      }
    }
  }
}
