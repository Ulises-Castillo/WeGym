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

  var body: some View {
    ScrollView {
      SearchBar(text: $searchText, isEditing: $isEditing)
        .onTapGesture { isEditing.toggle() }
        .padding()

      VStack(alignment: .leading) {
        HStack { Spacer() }
        ForEach((0...10), id: \.self) { _ in
          Button {
            showChatView.toggle()
            mode.wrappedValue.dismiss()
          } label: {
            ChatUserCell()
          }
        }
      }
    }
  }
}

#Preview {
  NewMessageView(showChatView: .constant(true))
}
