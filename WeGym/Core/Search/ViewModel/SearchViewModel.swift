//
//  SearchViewModel.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/19/23.
//

import SwiftUI
import Firebase

enum SearchViewModelConfig: Hashable {
    case followers(String)
    case following(String)
    case likes(String)
    case search
    case newMessage

    var navigationTitle: String {
        switch self {
        case .followers:
            return "Followers"
        case .following:
            return "Following"
        case .likes:
            return "Likes"
        case .search:
            return "Search"
        case .newMessage:
            return "NewMessage"
        }
    }
}

@MainActor
class SearchViewModel: ObservableObject {
    @Published var users = [User]()
    private let config: SearchViewModelConfig
    private var lastDoc: QueryDocumentSnapshot?

    init(config: SearchViewModelConfig) {
        self.config = config
        fetchUsers(forConfig: config)
    }

    func fetchUsers() async {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let query = FirestoreConstants.UserCollection.limit(to: 20)

        if let last = lastDoc { //TODO: integrate with UserService Cache, single source of truth + this paging logic can be used for cache
            let next = query.start(afterDocument: last)
          guard let snapshot = try? await next.getDocuments(source: .cache) else { return } //TODO: test .cache here
            self.lastDoc = snapshot.documents.last
            self.users.append(contentsOf: snapshot.documents.compactMap({ try? $0.data(as: User.self) }))
        } else {
          guard let snapshot = try? await query.getDocuments(source: .cache) else { return } //TODO: and here
            self.lastDoc = snapshot.documents.last
            self.users = snapshot.documents
                .compactMap({ try? $0.data(as: User.self) })
                .filter({ $0.id != currentUid })
        }
    }

    func fetchUsers(forConfig config: SearchViewModelConfig) {
        Task {
            switch config {
            case .followers(let uid):
                try await fetchFollowerUsers(forUid: uid)
            case .following(let uid):
                try await fetchFollowingUsers(forUid: uid)
            case .likes(let trainingSessionId):
              try await fetchTrainingSessionLikesUsers(forId: trainingSessionId)
            case .search, .newMessage:
                await fetchUsers()
            }
        }
    }

    private func fetchTrainingSessionLikesUsers(forId trainingSessionId: String) async throws {
        guard let snapshot = try? await FirestoreConstants.TrainingSessionsCollection.document(trainingSessionId).collection("training_session-likes").getDocuments() else { return }
        try await fetchUsers(snapshot)
    }

    private func fetchFollowerUsers(forUid uid: String) async throws {
        guard let snapshot = try? await FirestoreConstants.FollowersCollection.document(uid).collection("user-followers").getDocuments() else { return }
        try await fetchUsers(snapshot)
    }

    private func fetchFollowingUsers(forUid uid: String) async throws {
        guard let snapshot = try? await FirestoreConstants.FollowingCollection.document(uid).collection("user-following").getDocuments() else { return }
        try await fetchUsers(snapshot)
    }

    private func fetchUsers(_ snapshot: QuerySnapshot?) async throws {
        guard let documents = snapshot?.documents else { return }

        for doc in documents {
            let user = try await UserService.fetchUser(withUid: doc.documentID)
            users.append(user)
        }
    }

    func filteredUsers(_ query: String) -> [User] {
        let lowercasedQuery = query.lowercased()
        return users.filter({
            $0.fullName?.lowercased().contains(lowercasedQuery) ?? false ||
            $0.username.contains(lowercasedQuery)
        })
    }
}

