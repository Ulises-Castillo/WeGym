//
//  NewMessageView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/26/23.
//

import SwiftUI

struct NewMessageView: View {
  @Environment(\.dismiss) var dismiss
  @StateObject var viewModel = NewMessageViewModel()
  @Binding var selectedUser: User?

  var body: some View {
    NavigationStack {
      ScrollView {
        TextField("To: ", text: $viewModel.searchText)
          .frame(height: 44)
          .padding(.leading)
          .background(Color(.systemGroupedBackground))

        LazyVStack {
          ForEach(viewModel.filteredUsers) { user in
            VStack {
              HStack {
                CircularProfileImageView(user: user, size: .small)

                Text(user.fullName ?? user.username)
                  .font(.subheadline)
                  .fontWeight(.semibold)

                Spacer()
              }
              .onTapGesture {
                dismiss()
                selectedUser = user
              }

              Divider()
                .padding(.leading, 40)
            }
            .padding(.leading)
          }
        }
      }
      .navigationTitle("New Message")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Cancel") {
            dismiss()
          }
          .foregroundColor(.primary)

        }
      }
    }
  }
}

struct NewMessageView_Previews: PreviewProvider {
  static var previews: some View {
    NewMessageView(selectedUser: .constant(nil))
  }
}
