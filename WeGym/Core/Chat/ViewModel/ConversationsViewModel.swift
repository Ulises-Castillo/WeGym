//
//  ConversationsViewModel.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/25/23.
//

import Foundation

class ConversationsViewModel: ObservableObject {
  @Published var recentMessages = [Message]()

  init() {
    Task { try await fetchRecentMessages() }
  }

  @MainActor
  func fetchRecentMessages() async throws {
    guard let uid = UserService.shared.currentUser?.id else { return }

    let query = FirestoreConstants.MessagesCollection.document(uid)
      .collection("recent-messages")
      .order(by: "timestamp", descending: true)

    let snapshot = try await query.getDocuments() //TODO: change all callbacks to try await for uniformity

    self.recentMessages = snapshot.documents.compactMap({ try? $0.data(as: Message.self) })
  }
}
