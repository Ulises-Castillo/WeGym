//
//  EditProfileView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/13/23.
//

import SwiftUI
import Kingfisher
import PhotosUI

struct EditProfileView: View {
//  @State private var username = ""

  @StateObject private var viewModel = EditProfileViewModel()
  @Environment(\.dismiss) var dismiss
  @ObservedObject var current = UserService.shared

//  init() {
//    self._current = StateObject(wrappedValue: UserService.shared)
//    self._viewModel = StateObject(wrappedValue: EditProfileViewModel(user: current.currentUser!))
//    self._username = State(initialValue: current.currentUser!.username)
//  }

  var body: some View {
    NavigationStack {
      VStack {
        VStack(spacing: 8) {
          Divider()

          PhotosPicker(selection: $viewModel.selectedImage) {
            VStack {
              if let image = viewModel.profileImage {
                image
                  .resizable()
                  .scaledToFill()
                  .frame(width: 72, height: 72)
                  .clipShape(Circle())
                  .foregroundColor(Color(.systemGray4))
              } else {
                CircularProfileImageView(user: current.currentUser, size: .large)
              }
              Text("Edit profile picture")
                .font(.footnote)
                .fontWeight(.semibold)
            }
          }
          .padding(.vertical, 8)

          Divider()
        }
        .padding(.bottom, 4)

        VStack {
          EditProfileRowView(title: "Name", placeholder: "Enter your name..", text: $viewModel.fullName)

          EditProfileRowView(title: "Bio", placeholder: "Enter your bio..", text: $viewModel.bio)
        }

        Spacer()
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Cancel") {
            dismiss()
          }
          .font(.subheadline)
        }

        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Done") {
            Task {
              try await viewModel.updateUserData()

              if let url = viewModel.updatedImageURL {
//                viewModel.user.profileImageUrl = url
                current.currentUser?.profileImageUrl = url
              }
//              viewModel.user.fullName = viewModel.fullName
//              UserService.shared.currentUser?.fullName = viewModel.fullName
              current.currentUser?.fullName = viewModel.fullName
//              viewModel.user.bio = viewModel.bio
//              UserService.shared.currentUser?.bio = viewModel.bio
              current.currentUser?.bio = viewModel.bio
              dismiss()
            }
          }
          .font(.subheadline)
          .fontWeight(.semibold)
        }
      }
//      .onReceive(viewModel.$user, perform: { user in //TODO: check this
//        current.currentUser = user
//      })
      .navigationTitle("Edit Profile")
      .navigationBarTitleDisplayMode(.inline)
    }

  }
}

struct EditProfileRowView: View {
  let title: String
  let placeholder: String
  @Binding var text: String

  var body: some View {

    HStack {
      Text(title)
        .padding(.leading, 8)
        .frame(width: 100, alignment: .leading)

      VStack {
        TextField(placeholder, text: $text)

        Divider()
      }
    }
    .font(.subheadline)
    .frame(height: 36)
  }
}
