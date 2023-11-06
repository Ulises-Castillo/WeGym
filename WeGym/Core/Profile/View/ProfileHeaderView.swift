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
        if viewModel.user.isCurrentUser {
          if viewModel.isLoading {
            ProgressView()
              .scaleEffect(1, anchor: .center)
              .progressViewStyle(CircularProgressViewStyle(tint: Color(.systemBlue)))
              .padding(.top, 15)
              .frame(maxWidth: .infinity)
          } else if !viewModel.favoritePersonalRecords.isEmpty {
            ForEach(viewModel.favoritePersonalRecords, id: \.self) { pr in
              HStack() {
                NavigationLink(value: SearchViewModelConfig.followers(viewModel.user.id)) {
                  UserStatView(value: pr.weight ?? 0, title: pr.type)
                }
                .disabled(!viewModel.user.isCurrentUser)
                .frame(maxWidth: .infinity)
              }
            }
            .foregroundColor(.primary)
            .padding(.trailing)
          } else {
            NavigationLink(value: SearchViewModelConfig.followers(viewModel.user.id)) {
              HStack {
                Image(systemName: "trophy")
                Text("Add Personal Record")
                  .font(.footnote)
              }
              .frame(maxWidth: .infinity)

            }
            Spacer()
          }
        }
      }
      .onAppear {
        viewModel.fetchFavoritePersonalRecords(viewModel.user.id)
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
      if viewModel.user.isCurrentUser {
        PersonalRecordsView()
      } else {
        //TODO: should toggle between lbs & kgs when viewing other users profiles (will  use button and append to nav $path)
      }
    }
  }

}
