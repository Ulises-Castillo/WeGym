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

  var body: some View {
    ScrollView {
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
