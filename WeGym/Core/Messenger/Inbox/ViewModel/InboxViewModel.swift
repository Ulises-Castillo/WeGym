//
//  InboxViewModel.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/26/23.
//

import Foundation
import Firebase
import Combine

@MainActor
class InboxViewModel: ObservableObject {
  @Published var recentMessages = [Message]()
  @Published var conversations = [Conversation]() // the fuck is this ?
  @Published var user: User?
  @Published var searchText = ""
  
  var unreadMessagesCount: Int {
    return recentMessages.filter({ !$0.read && !$0.isFromCurrentUser }).count
  }

  var filteredMessages: [Message] {
    guard let currentUser = user else { return [] }

    return recentMessages.filter { message in
      guard let user = message.user, currentUser != user else { return false }

      if searchText.isEmpty {
        return true
      } else {
        let searchText = searchText.lowercased()
        return user.fullName?.lowercased().contains(searchText) ?? false ||
        user.username.contains(searchText)
      }
    }
  }

  var didCompleteInitialLoad = false
  private var firestoreListener: ListenerRegistration?
  private var cancellables = Set<AnyCancellable>()

  init() {
    InboxService.shared.reset() //CRASH fix: reset singleton!
    setupSubscribers()
    observeRecentMessages()
  }

  private func setupSubscribers() {
    UserService.shared.$currentUser.sink { [weak self] user in
      self?.user = user
    }.store(in: &cancellables)

    InboxService.shared.$documentChanges.sink { [weak self] changes in
      guard let self = self, !changes.isEmpty else {
        self?.didCompleteInitialLoad = true //TODO: test all cases
        return
      }

      if !self.didCompleteInitialLoad {
        self.loadInitialMessages(fromChanges: changes)
      } else {
        self.updateMessages(fromChanges: changes)
      }
    }.store(in: &cancellables)
  }

  func observeRecentMessages() {
    InboxService.shared.observeRecentMessages()
  }

  private func loadInitialMessages(fromChanges changes: [DocumentChange]) {
    var messagesTemp = changes.compactMap{ try? $0.document.data(as: Message.self) }

    Task {
      for (i, message) in messagesTemp.enumerated() {
        messagesTemp[i].user = try await UserService.fetchUser(withUid: message.chatPartnerId)
      }
      self.recentMessages = messagesTemp
      self.didCompleteInitialLoad = true
    }
  }

  private func updateMessages(fromChanges changes: [DocumentChange]) {
    for change in changes {
      if change.type == .added {
        self.createNewConversation(fromChange: change)
      } else if change.type == .modified {
        self.updateMessagesFromExisitingConversation(fromChange: change)
      }
    }
  }

  private func createNewConversation(fromChange change: DocumentChange) {
    guard var message = try? change.document.data(as: Message.self) else { return }

    UserService.fetchUser(withUid: message.chatPartnerId) { user in
      message.user = user
      self.recentMessages.insert(message, at: 0)
    }
  }

  private func updateMessagesFromExisitingConversation(fromChange change: DocumentChange) {
    guard var message = try? change.document.data(as: Message.self) else { return }
    guard let index = self.recentMessages.firstIndex(where: {
      $0.user?.id ?? "" == message.chatPartnerId
    }) else { return }
    guard let user = self.recentMessages[index].user else { return }
    message.user = user

    self.recentMessages.remove(at: index)
    self.recentMessages.insert(message, at: 0)
  }

  func deleteMessage(_ message: Message) async throws {
    do {
      recentMessages.removeAll(where: { $0.id == message.id })
      try await InboxService.deleteMessage(message)
    } catch {
      // TODO: If deletion fails add message back at original index
    }
  }
}
