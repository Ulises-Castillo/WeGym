//
//  FeedView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/14/23.
//

import SwiftUI

struct FeedView: View {
  @StateObject var viewModel = FeedViewModel()
  
  var body: some View {
    NavigationStack {
      ScrollView {
        LazyVStack(spacing: 30) {
          ForEach(viewModel.posts) { post in
            FeedCell(post: post)
          }
        }
        .padding(.top, 8)
      }
      .navigationTitle("Feed")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Text("WeGym")
            .font(.title3)
            .fontWeight(.semibold)
          
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Image(systemName: "paperplane")
            .imageScale(.large)
        }
      }
    }
  }
}

#Preview {
  FeedView()
}
