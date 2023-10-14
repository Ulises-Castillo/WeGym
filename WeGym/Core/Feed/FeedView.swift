//
//  FeedView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/14/23.
//

import SwiftUI

struct FeedView: View {
    var body: some View {
      NavigationStack {
        ScrollView {
          LazyVStack(spacing: 30) {
            ForEach(0 ... 12, id: \.self) { post in
              FeedCell()
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
