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

          HStack(spacing: 24) {
            NavigationLink(value: CurrentUserProfileNavigation.trainingSessions) {
              UserStatView(value: String(viewModel.user.stats?.trainingSessions ?? 0), title: "Workouts")
            }

            NavigationLink(value: CurrentUserProfileNavigation.followers(viewModel.user.id)) {
              UserStatView(value: String(viewModel.user.stats?.followers ?? 0), title: "Followers")
            }
//            .disabled(viewModel.user.stats?.followers == 0)

            NavigationLink(value: CurrentUserProfileNavigation.following(viewModel.user.id)) {
              UserStatView(value: String(viewModel.user.stats?.following ?? 0), title: "Following")
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
        case .followers(let userId):
          UserListView(viewModel: SearchViewModel(config: SearchViewModelConfig.followers(userId)))
        case .following(let userId):
          UserListView(viewModel: SearchViewModel(config: SearchViewModelConfig.following(userId)))
        default:
          Text(selectedSettingsOption?.title ?? "Workouts")
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
