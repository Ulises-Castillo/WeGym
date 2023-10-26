//
//  SelectedGroupMembersView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/25/23.
//

import SwiftUI

struct SelectedGroupMembersView: View {
  var body: some View {
    ScrollView(.horizontal) {
      HStack {
        ForEach((0...10), id: \.self) { _ in
          ZStack(alignment: .topTrailing) {
            VStack {

              CircularProfileImageView(user: User.MOCK_USERS_2[0], size: .medium)

              Text("Eddie Brock")
                .font(.system(size: 11, weight: .semibold))
                .multilineTextAlignment(.center)
            }.frame(width: 64)

            Button {
              print("Deselect user...")
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

#Preview {
  SelectedGroupMembersView()
}
