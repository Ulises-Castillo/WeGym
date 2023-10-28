//
//  NewMessageView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/24/23.
//

import SwiftUI

struct NewMessageView: View {
  @Binding var showChatView: Bool
  @Environment(\.presentationMode) var mode
  @State private var searchText = ""
  @State private var isEditing = false
  @Binding var user: User?
  @ObservedObject var viewModel = NewMessageViewModel()

  var body: some View {
    ScrollView {
      SearchBar(text: $searchText, isEditing: $isEditing)
        .onTapGesture { isEditing.toggle() }
        .padding()

      VStack(alignment: .leading) {
        HStack { Spacer() }
        ForEach(viewModel.users, id: \.self) { user in
          Button {
            showChatView.toggle()
            self.user = user
            mode.wrappedValue.dismiss()
          } label: {
            ChatUserCell(user: user)
          }
        }
      }
    }
  }
}
