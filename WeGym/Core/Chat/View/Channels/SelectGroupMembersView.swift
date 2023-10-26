//
//  SelectGroupMembersView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/25/23.
//

import SwiftUI

struct SelectGroupMembersView: View {
  @State private var searchText = ""
  

  var body: some View {
    NavigationView {
      VStack {

        SearchBar(text: $searchText, isEditing: .constant(false))
          .padding()

        SelectedGroupMembersView()

        ScrollView {
          VStack {
            ForEach((0...10), id: \.self) { _ in
              SelectableUserCell(selectableUser: SelectableUser(user: User.MOCK_USERS_2[0]))
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
