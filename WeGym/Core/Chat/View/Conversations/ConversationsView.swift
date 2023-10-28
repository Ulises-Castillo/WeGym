//
//  ConversationsView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/24/23.
//

import SwiftUI

struct ConversationsView: View {
  @State private var showNewMessageView = false
  @State private var showChatView = false
  @State var selectedUser: User?
  @ObservedObject var viewModel = ConversationsViewModel()

  var body: some View {
    ZStack(alignment: .bottomTrailing) {

      if let user = selectedUser {
        NavigationLink(
          destination: ChatView(user: user),
          isActive: $showChatView,
          label: { })
      }

      ScrollView {
        VStack(alignment: .leading) {
          HStack { Spacer() }
          ForEach(viewModel.recentMessages) { messsage in
            ConversationCell(viewModel: ConversationCellViewModel(messsage))
          }
        }
      }

      FloatingButton(show: $showNewMessageView)
        .sheet(isPresented: $showNewMessageView, content: {
          NewMessageView(showChatView: $showChatView, user: $selectedUser)
        })
    }
  }
}

#Preview {
  ConversationsView()
}
