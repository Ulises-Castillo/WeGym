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
    let snapshot = try await Firestore.firestore().collection("posts").getDocuments()
    self.posts = try snapshot.documents.compactMap({ try $0.data(as: Post.self) })
    
    for i in 0..<posts.count {
      let post = posts[i]
      let ownwerUid = post.ownwerUid
      let postUser = try await UserService.fetchUser(withUid: ownwerUid)
      // Single Source of Truth on the backend
      // setting the user on the post such that the user info will be up to date
      // yes, we could store username etc. w/ Post, however consider what would
      // happen if the user had changed thier info (name, etc.) since making the
      // Post. The user info stored with the Post would be outdated
      posts[i].user = postUser
    }
  }
}
