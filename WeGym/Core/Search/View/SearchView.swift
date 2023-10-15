//
//  SearchView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/12/23.
//

import SwiftUI

struct SearchView: View {
  @State private var searchText = ""
  @State var viewModel = SearchViewModel()
  
  var body: some View {
    NavigationStack {
      ScrollView {
        LazyVStack(spacing: 12) {
          ForEach(viewModel.users) { user in
            NavigationLink(value: user) {
              HStack {
                CircularProfileImageView(user: user, size: .xSmall)
                
                VStack(alignment: .leading) {
                  Text(user.username)
                    .fontWeight(.semibold)
                  
                  if let fullName = user.fullName {
                    Text(fullName)
                  }
                }
                .font(.footnote)
                
                Spacer()
              }
              .padding(.horizontal)
            }
          }
        }
        .foregroundColor(.black)
        .padding(.top, 8)
        .searchable(text: $searchText, prompt: "Search..")
      }
      .navigationDestination(for: User.self, destination: { user in
        ProfileView(user: user)
          .navigationBarBackButtonHidden()
      })
      .navigationTitle("Add Gym Bros")
      .navigationBarTitleDisplayMode(.inline)
    }
    .onAppear {
      print("# of users: \(viewModel.users.count)") //FIXME: why are users disappearing when SearchView() called from the scheduler?
    }
  }
    
}

#Preview {
  SearchView()
}
