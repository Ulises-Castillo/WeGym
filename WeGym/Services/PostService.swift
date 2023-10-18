//
//  PostService.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/14/23.
//

import Foundation
import Firebase

struct PostService {
  
  private static let postsCollection = Firestore.firestore().collection("posts")
  
  static func fetchFeedPosts() async throws -> [Post] {
    
    let snapshot = try await postsCollection.getDocuments()
    var posts = try snapshot.documents.compactMap({ try $0.data(as: Post.self) })
    
    for i in 0..<posts.count {
      let post = posts[i]
      let ownerUid = post.ownerUid
      let postUser = try await UserService.fetchUser(withUid: ownerUid)
      // Single Source of Truth on the backend
      // setting the user on the post such that the user info will be up to date
      // yes, we could store name etc. w/ Post, however consider what would
      // happen if the user had changed thier info (name, etc.) since making the
      // Post. The user info stored with the Post would be outdated
      posts[i].user = postUser
    }
    return posts
  }
  
  
  static func fetchUserPosts(uid: String) async throws -> [Post] {
    let snapshot = try await postsCollection.whereField("ownerUid", isEqualTo: uid).getDocuments()
    return try snapshot.documents.compactMap({ try $0.data(as: Post.self) })
  }
}
