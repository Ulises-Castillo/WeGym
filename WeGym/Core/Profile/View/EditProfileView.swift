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
  @State private var username = ""
  @State private var isUploading = false

  @StateObject private var viewModel: EditProfileViewModel
  @Environment(\.dismiss) var dismiss

  init() {
    self._viewModel = StateObject(wrappedValue: EditProfileViewModel(user: UserService.shared.currentUser!))
    self._username = State(initialValue: UserService.shared.currentUser!.username)
  }

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
                CircularProfileImageView(user: UserService.shared.currentUser!, size: .large)
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
            isUploading = true
            Task {
              UserService.shared.currentUser?.fullName = viewModel.fullName
              UserService.shared.currentUser?.bio = viewModel.bio
              UserService.shared.currentUser?.profileImageUrl = nil

              dismiss()

              try await viewModel.updateUserData()
              if let url = viewModel.updatedImageURL { //TODO: the image is local, set it instantly, until we have the updated URL, perhaps just always use stored local image // KFImage prob handles UIImages automatically
                UserService.shared.currentUser?.profileImageUrl = url
              }
            }
          }
          .font(.subheadline)
          .fontWeight(.semibold)
        }
      }
      .onReceive(viewModel.$user, perform: { user in
        UserService.shared.currentUser = user
      })
      .navigationTitle("Edit Profile")
      .navigationBarTitleDisplayMode(.inline)
      .overlay(Group {
        if isUploading {
          ProgressView()
            .scaleEffect(1, anchor: .center)
            .progressViewStyle(CircularProgressViewStyle(tint: Color(.systemBlue)))
            .padding(.top, 15)
            .frame(width: 50)
        }
      })
    }.disabled(isUploading)

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
