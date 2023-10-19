//
//  EditProfileView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/13/23.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
  @Environment(\.dismiss) var dismiss
  @StateObject var viewModel: EditProfileViewModel
  
  init(user: User) {
    self._viewModel = StateObject(wrappedValue: EditProfileViewModel(user: user))
  }
  
  var body: some View {
    VStack {
      // toolbar
      VStack {
        HStack {
          Button {
            dismiss()
          } label: {
            Image(systemName: "xmark")
          }
          .foregroundColor(.red)
          
          Spacer()
          
          Text("Edit Profile")
            .font(.subheadline)
            .fontWeight(.semibold)
          
          Spacer()
          
          Button {
            Task { try await viewModel.updateUserData() }
            dismiss()
          } label: {
            Image(systemName: "checkmark")
          }
          .foregroundColor(.green)
          
        }
        .padding(.horizontal)
        Divider()
      }
      
      // edit profile pic
      PhotosPicker(selection: $viewModel.selectedImage) {
        VStack {
          if let image = viewModel.profileImage {
            image
              .resizable()
              .foregroundColor(.white)
              .background(.gray)
              .clipShape(Circle())
              .frame(width: 80, height: 80)
          } else {
            CircularProfileImageView(user: viewModel.user, size: .large)
          }
          
          Text("Edit profile picture")
            .font(.footnote)
            .fontWeight(.semibold)
          
          Divider()
        }
        .padding(.vertical, 8)
      }
      
      
      // edit profile info
      VStack {
        EditProfileRowView(title: "Name", placeholder: "Enter your name", text: $viewModel.fullName)
        EditProfileRowView(title: "Bio", placeholder: "Enter your bio", text: $viewModel.bio)
      }
      
      Spacer()
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

#Preview {
  EditProfileView(user: User.MOCK_USERS[0])
}
