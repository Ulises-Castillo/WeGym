//
//  MessagesView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/26/23.
//

import SwiftUI

struct MessagesView: View {
  @State private var showNewMessageView = false
  @EnvironmentObject var viewModel: InboxViewModel
  @State private var selectedUser: User?
  @Environment(\.colorScheme) var colorScheme
  @Binding var path: [WGNavigation]
  
  var body: some View {
    NavigationStack(path: $path) {
      List {
        ForEach(viewModel.filteredMessages) { recentMessage in
          ZStack {
            NavigationLink(value: WGNavigation.chat(recentMessage.user!)) {
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
      .onNotification { _ in
        showNewMessageView = false
      }
      .onChange(of: selectedUser, perform: { newValue in
        guard let user = newValue else { return }
        path.append(.chat(user))
      })
      .sheet(isPresented: $showNewMessageView) {
        NewMessageView(selectedUser: $selectedUser)
      }
      .navigationDestination(for: WGNavigation.self) { screen in
        switch screen {
        case .chat(let user):
          ChatView(user: user)
        case .trainingSessions:
          Text("Workouts")
        case .followers(let userId):
          UserListView(viewModel: SearchViewModel(config: SearchViewModelConfig.followers(userId)))
        case .following(let userId):
          UserListView(viewModel: SearchViewModel(config: SearchViewModelConfig.following(userId)))
        case .profile(let user):
          ProfileView(user: user)
        default:
          Text("default")
        }
      }
      .overlay { 
        if !viewModel.didCompleteInitialLoad {
          ProgressView()
        } else if viewModel.recentMessages.isEmpty {
          Text("No messages yet")
            .foregroundColor(.secondary)
        }
      }
      .onAppear {
        Task { try await viewModel.updateUserInfo() }
      }
      .navigationTitle("Messages")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Image(systemName: "square.and.pencil.circle.fill")
            .resizable()
            .frame(width: 39, height: 39)
            .foregroundStyle(Color(.systemBlue), colorScheme == .light ? .white : .black)
            .onTapGesture {
              selectedUser = nil
              showNewMessageView.toggle()
            }
        }
      }
    }
  }
}

struct InboxView_Previews: PreviewProvider {
  static var previews: some View {
    MessagesView(path: .constant([WGNavigation]()))
  }
}
