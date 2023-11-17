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

          HStack(spacing: 16) {
            NavigationLink(value: CurrentUserProfileNavigation.settings) {
              UserStatView(value: String(33), title: "Workouts")
            }

            NavigationLink(value: CurrentUserProfileNavigation.settings) {
              UserStatView(value: String(15), title: "Followers")
            }
//            .disabled(viewModel.user.stats?.followers == 0)

            NavigationLink(value: CurrentUserProfileNavigation.settings) {
              UserStatView(value: String(9), title: "Following")
            }
//            .disabled(viewModel.user.stats?.following == 0)
          }
          .padding(.trailing)
          .foregroundColor(.primary)
        }
      }
      .navigationTitle(UserService.shared.currentUser?.username ?? "")
      .navigationBarTitleDisplayMode(.inline)
      .navigationDestination(for: CurrentUserProfileNavigation.self) { screen in
        switch screen {
        case .personalRecords:
          PersonalRecordsView()
        default:
          Text(selectedSettingsOption?.title ?? "Followers")
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
