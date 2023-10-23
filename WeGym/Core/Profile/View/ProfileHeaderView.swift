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
    @StateObject var currentUser = CurrentUser.shared

    var body: some View {
        VStack {
            HStack {
              CircularProfileImageView(user: viewModel.user.isCurrentUser ? CurrentUser.shared.user! : viewModel.user, size: .large)
                    .padding(.leading)

                Spacer()

//                HStack(spacing: 16) {
//                    UserStatView(value: viewModel.user.stats?.posts, title: "Posts")
//
//                    NavigationLink(value: SearchViewModelConfig.followers(viewModel.user.id)) {
//                        UserStatView(value: viewModel.user.stats?.followers, title: "Followers")
//                    }
//                    .disabled(viewModel.user.stats?.followers == 0)
//
//                    NavigationLink(value: SearchViewModelConfig.following(viewModel.user.id)) {
//                        UserStatView(value: viewModel.user.stats?.following, title: "Following")
//                    }
//                    .disabled(viewModel.user.stats?.following == 0)
//                }
//                .padding(.trailing)
            }

            VStack(alignment: .leading, spacing: 4) {
                if let fullname = viewModel.user.isCurrentUser ? CurrentUser.shared.user?.fullName : viewModel.user.fullName {
                    Text(fullname)
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .padding(.leading)
                }


                if let bio = viewModel.user.isCurrentUser ? CurrentUser.shared.user?.bio : viewModel.user.bio {
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
            UserListView(config: config)
        }
    }

}
