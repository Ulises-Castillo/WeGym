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

        if !viewModel.favoritePersonalRecords.isEmpty {
          ForEach(viewModel.favoritePersonalRecords, id: \.self) { pr in
            HStack(spacing: 16) {
              NavigationLink(value: SearchViewModelConfig.followers(viewModel.user.id)) {
                UserStatView(value: pr.weight ?? 0, title: pr.type)
              }
              .disabled(!viewModel.user.isCurrentUser)
            }
          }
          .foregroundColor(.primary)
          .padding(.trailing)
        } else {
          NavigationLink(value: SearchViewModelConfig.followers(viewModel.user.id)) { //FIXME: button looks terrible
            VStack {
              Image(systemName: "plus")
              Text("Add PR")
                .padding(.top, 1)
            }
          }
          .foregroundColor(Color(.systemBlue))
          .padding(.trailing, 21)
          Spacer()
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
      PersonalRecordsView()
    }
  }

}
