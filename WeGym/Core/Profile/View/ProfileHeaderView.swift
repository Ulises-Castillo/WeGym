//
//  ProfileHeaderView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/14/23.
//

import SwiftUI
import Kingfisher

struct ProfileHeaderView: View {
  @ObservedObject var viewModel: ProfileViewModel
  @State var updatedProfileImageUrl: String?
  @StateObject var userService = UserService.shared

  var body: some View {
    VStack {
      HStack {
        CircularProfileImageView(user: viewModel.user.isCurrentUser ? userService.currentUser : viewModel.user, size: .large)
          .padding(.leading)

        Spacer()

        HStack(spacing: 16) {
          NavigationLink(value: SearchViewModelConfig.followers(viewModel.user.id)) {
            UserStatView(value: 315, title: "Squat")
          }
          .disabled(!viewModel.user.isCurrentUser)

          NavigationLink(value: SearchViewModelConfig.followers(viewModel.user.id)) {
            UserStatView(value: 245, title: "Bench")
          }
          .disabled(!viewModel.user.isCurrentUser)

          NavigationLink(value: SearchViewModelConfig.following(viewModel.user.id)) {
            UserStatView(value: 365, title: "Deadlift")
          }
          .disabled(!viewModel.user.isCurrentUser)


        }
        .foregroundColor(.primary)
        .padding(.trailing)
      }

      VStack(alignment: .leading, spacing: 4) {
        if let fullname = viewModel.user.isCurrentUser ? userService.currentUser?.fullName : viewModel.user.fullName {
          Text(fullname)
            .font(.footnote)
            .fontWeight(.semibold)
            .padding(.leading)
        }


        if let bio = viewModel.user.isCurrentUser ? userService.currentUser?.bio : viewModel.user.bio {
          Text(bio)
            .font(.footnote)
            .padding(.leading)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)

      ProfileActionButtonView(viewModel: viewModel)
        .padding(.top)
    }
    .navigationDestination(for: SearchViewModelConfig.self) { config in
      PersonalRecordsView()
    }
  }

}
