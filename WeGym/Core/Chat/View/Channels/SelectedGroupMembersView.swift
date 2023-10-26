//
//  SelectedGroupMembersView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/25/23.
//

import SwiftUI

struct SelectedGroupMembersView: View {
  @ObservedObject var viewModel: SelectGroupMembersViewModel

  var body: some View {
    ScrollView(.horizontal) {
      HStack {
        ForEach(viewModel.selectedUsers) { selectableUser in
          ZStack(alignment: .topTrailing) {
            VStack {

              CircularProfileImageView(user: selectableUser.user, size: .medium)

              Text(selectableUser.user.fullName ?? selectableUser.user.username)
                .font(.system(size: 11, weight: .semibold))
                .multilineTextAlignment(.center)
            }.frame(width: 64)

            Button {
              viewModel.selectUser(selectableUser, isSelected: false)
            } label: {
              Image(systemName: "xmark")
                .resizable()
                .scaledToFit()
                .frame(width: 10, height: 10)
                .padding(4)
            }
            .background(Color(.gray))
            .foregroundColor(.white)
            .clipShape(Circle())
          }
        }
      }
    }
    .animation(.spring())
    .padding()
  }
}
