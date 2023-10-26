//
//  SelectGroupMembersView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/25/23.
//

import SwiftUI

struct SelectGroupMembersView: View {
  @State private var searchText = ""
  @ObservedObject var viewModel = SelectGroupMembersViewModel()


  var body: some View {
    NavigationView {
      VStack {

        SearchBar(text: $searchText, isEditing: .constant(false))
          .padding()

        SelectedGroupMembersView()

        ScrollView {
          VStack {
            ForEach(viewModel.selectableUsers) { selectableUser in
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
      print("dismiss view..")
    } label: {
      Text("Cancel")
    }
  }
}

#Preview {
  SelectGroupMembersView()
}
