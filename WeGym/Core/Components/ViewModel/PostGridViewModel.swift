//
//  PostGridViewModel.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/14/23.
//

import Foundation

import SwiftUI
import Firebase

enum PostGridConfiguration {
    case explore
    case profile(User)
}

class PostGridViewModel: ObservableObject {
    @Published var posts = [Post]()
    private let config: PostGridConfiguration
    private var lastDoc: QueryDocumentSnapshot?

    init(config: PostGridConfiguration) {
        self.config = config
        fetchPosts(forConfig: config)
    }

    func fetchPosts(forConfig config: PostGridConfiguration) {
        switch config {
        case .explore:
            fetchExplorePagePosts()
        case .profile(_):
//            Task { try await fetchUserPosts(forUser: user) }//TODO: add this
          break
        }
    }

    func fetchExplorePagePosts() {
        let query = FirestoreConstants.PostsCollection.limit(to: 20).order(by: "timestamp", descending: true)

        if let last = lastDoc {
            let next = query.start(afterDocument: last)
            next.getDocuments { snapshot, _ in
                guard let documents = snapshot?.documents, !documents.isEmpty else { return }
                self.lastDoc = snapshot?.documents.last
                self.posts.append(contentsOf: documents.compactMap({ try? $0.data(as: Post.self) }))
            }
        } else {
            query.getDocuments { snapshot, _ in
                guard let documents = snapshot?.documents else { return }
                self.posts = documents.compactMap({ try? $0.data(as: Post.self) })
                self.lastDoc = snapshot?.documents.last
            }
        }
    }

//    @MainActor //TODO: bring this in
//    func fetchUserPosts(forUser user: User) async throws {
//        let posts = try await PostService.fetchUserPosts(user: user)
//        self.posts = posts
//    }
}
