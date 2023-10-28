//
//  InboxView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/26/23.
//

import SwiftUI

struct InboxView: View {
  @State private var showNewMessageView = false
  @StateObject var viewModel = InboxViewModel()
  @State private var selectedUser: User?
  @Environment(\.colorScheme) var colorScheme

  var body: some View {
    NavigationStack {
      List {
        ForEach(viewModel.filteredMessages) { recentMessage in
          ZStack {
            NavigationLink(value: recentMessage) {
              EmptyView()
            }.opacity(0.0)
            
            InboxRowView(message: recentMessage, viewModel: viewModel)
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
      .navigationDestination(for: Message.self, destination: { message in
        if let user = message.user {
          ChatView(user: user)
        }
      })
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
    InboxView()
  }
}
