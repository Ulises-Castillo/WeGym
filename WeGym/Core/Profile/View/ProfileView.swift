//
//  ProfileView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/12/23.
//

import SwiftUI

struct ProfileView: View {
  let user: User
  @StateObject var viewModel: ProfileViewModel

  init(user: User) {
    self.user = user
    self._viewModel = StateObject(wrappedValue: ProfileViewModel(user: user))
  }

  var body: some View {
    ScrollView {
      VStack(spacing: 24) {
        ProfileHeaderView(viewModel: viewModel)

        //                PostGridView(config: .profile(user))

        HStack(spacing: 24) {
          NavigationLink(value: CurrentUserProfileNavigation.trainingSessions) {
            UserStatView(value: String(viewModel.user.stats?.trainingSessions ?? 0), title: "Workouts")
          }
          .disabled(viewModel.user.stats?.trainingSessions == 0)

          NavigationLink(value: CurrentUserProfileNavigation.followers(viewModel.user.id)) {
            UserStatView(value: String(viewModel.user.stats?.followers ?? 0), title: "Followers")
          }
          .disabled(viewModel.user.stats?.followers == 0)

          NavigationLink(value: CurrentUserProfileNavigation.following(viewModel.user.id)) {
            UserStatView(value: String(viewModel.user.stats?.following ?? 0), title: "Following")
          }
          .disabled(viewModel.user.stats?.following == 0)
        }
        .padding(.trailing)
        .foregroundColor(.primary)
      }
      .padding(.top)
    }
    .navigationTitle(user.username)
    .navigationBarTitleDisplayMode(.inline)

  }
}
