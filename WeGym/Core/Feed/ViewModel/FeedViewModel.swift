//
//  FeedViewModel.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/14/23.
//

import Foundation
import Firebase

class FeedViewModel: ObservableObject {
  @Published var posts = [Post]()
  
  init() {
    Task { try await fetchPosts() }
  }
  
  @MainActor
  func fetchPosts() async throws {
    posts = try await PostService.fetchFeedPosts()
  }
}
