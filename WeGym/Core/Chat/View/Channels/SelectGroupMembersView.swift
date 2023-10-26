//
//  SelectGroupMembersView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/25/23.
//

import SwiftUI

struct SelectGroupMembersView: View {
  @State private var searchText = ""
  @State private var isEditing = false
  @ObservedObject var viewModel = SelectGroupMembersViewModel()
  @Environment(\.presentationMode) var mode


  var body: some View {
    NavigationView {
      VStack {

        SearchBar(text: $searchText, isEditing: $isEditing)
          .onTapGesture { isEditing.toggle() }
          .padding()

        if !viewModel.selectableUsers.isEmpty {
          SelectedGroupMembersView(viewModel: viewModel)
        }

        ScrollView {
          VStack {
            ForEach(
              searchText.isEmpty ? viewModel.selectableUsers : viewModel.filteredUsers(searchText)
            ) { selectableUser in
              Button {
                viewModel.selectUser(selectableUser, isSelected: !selectableUser.isSelected)
              } label: {
                SelectableUserCell(selectableUser: selectableUser)
              }
            }
          }
        }
      }
      .navigationBarItems(leading: cancelButton, trailing: nextButton )
      .navigationTitle("New Group")
      .navigationBarTitleDisplayMode(.inline)
    }
  }

  var nextButton: some View {
    NavigationLink(destination: Text("Destination"), label: { Text("Next").bold() })
  }

  var cancelButton: some View {
    Button {
      mode.wrappedValue.dismiss()
    } label: {
      Text("Cancel")
    }
  }
}

#Preview {
  SelectGroupMembersView()
}
