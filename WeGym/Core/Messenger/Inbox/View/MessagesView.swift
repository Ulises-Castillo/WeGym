//
//  MessagesView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/26/23.
//

import SwiftUI

struct MessagesView: View {
  @State private var showNewMessageView = false
  @StateObject var viewModel = InboxViewModel()
  @State private var selectedUser: User?
  @Environment(\.colorScheme) var colorScheme
  @Binding var path: [MessagesNavigation]

  var body: some View {
    NavigationStack(path: $path) {
      List {
        ForEach(viewModel.filteredMessages) { recentMessage in
          ZStack {
            NavigationLink(value: MessagesNavigation.chat(recentMessage.user!)) {
              EmptyView()
            }.opacity(0.0).disabled(recentMessage.user == nil)

            MessageRowView(message: recentMessage, viewModel: viewModel)
              .onAppear {
                if recentMessage == viewModel.recentMessages.last {
                  print("DEBUG: Paginate here..")
                }
              }
          }
        }
        .listRowInsets(EdgeInsets())
        .padding(.vertical)
        .padding(.trailing, 8)
        .padding(.leading, 20)
      }
      .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .automatic), prompt: "Search")
      .disableAutocorrection(true)
      .autocapitalization(.none)
      .listStyle(PlainListStyle())
      .fullScreenCover(isPresented: $showNewMessageView, content: {
        NewMessageView(selectedUser: $selectedUser)
      })
      .navigationDestination(for: MessagesNavigation.self) { screen in
        switch screen {
        case .chat(let user):
          ChatView(user: user)
        }
      }
      .overlay { if !viewModel.didCompleteInitialLoad { ProgressView() } }
      .navigationTitle("Messages")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Image(systemName: "square.and.pencil.circle.fill")
            .resizable()
            .frame(width: 39, height: 39)
            .foregroundStyle(Color(.systemBlue), colorScheme == .light ? .white : .black)
            .onTapGesture {
              showNewMessageView.toggle()
              selectedUser = nil
            }
        }
      }
    }
  }
}

struct InboxView_Previews: PreviewProvider {
  static var previews: some View {
    MessagesView(path: .constant([MessagesNavigation]()))
  }
}
