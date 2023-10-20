//
//  SearchView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/12/23.
//

import SwiftUI

struct SearchView: View {
  @State var searchText = ""
  @State var inSearchMode = false
  @State var showingNotificationsSheet = false

  var body: some View {
    NavigationStack {
      UserListView(config: .search)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: User.self) { user in
          ProfileView(user: user)
        }
        .toolbar {
          ToolbarItem(placement: .navigationBarTrailing) {
            Button {
              showingNotificationsSheet.toggle()
            } label: {
              Image(systemName: "bell")
                .foregroundColor(.primary)
                .padding(.horizontal, 9)
            }
          }
        }
        .sheet(isPresented: $showingNotificationsSheet) {
          NotificationsView()
            .foregroundColor(.primary)
        }
    }
  }
}
