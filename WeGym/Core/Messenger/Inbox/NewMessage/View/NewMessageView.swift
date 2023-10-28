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
          .autocorrectionDisabled(true)
          .autocapitalization(.none)

        LazyVStack {
          ForEach(viewModel.filteredUsers) { user in
            VStack {
              HStack(spacing: 15) {
                CircularProfileImageView(user: user, size: .small)

                VStack(alignment: .leading) {
                  Text(user.fullName ?? user.username)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                  if user.fullName != nil {
                    Text(user.username)
                      .font(.footnote)
                      .fontWeight(.regular)
                      .foregroundColor(.secondary)
                  }
                }

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
