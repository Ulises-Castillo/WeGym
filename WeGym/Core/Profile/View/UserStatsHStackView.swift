//
//  UserStatsHStackView.swift
//  WeGym
//
//  Created by Ulises Castillo on 11/17/23.
//

import SwiftUI

struct UserStatsHStackView: View {
  @ObservedObject var viewModel: ProfileViewModel

  var body: some View {
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
}

//#Preview {
//  UserStatsHStackView()
//}
