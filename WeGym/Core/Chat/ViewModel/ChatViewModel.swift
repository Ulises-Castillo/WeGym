//
//  ChatViewModel.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/24/23.
//

import Firebase

class ChatViewModel: ObservableObject {

  @Published var messages = [Message]()
  let user: User

  init(user: User) {
    self.user = user
    fetchMessages()
  }

  func fetchMessages() {
    guard let currentUid = UserService.shared.currentUser?.id else { return }
    let chatPartnerId = user.id

    let query = FirestoreConstants
      .MessagesCollection
      .document(currentUid)
      .collection(chatPartnerId)
      .order(by: "timestamp", descending: false)

    query.addSnapshotListener { snapshot, _ in
      guard let changes = snapshot?.documentChanges.filter({ $0.type == .added }) else { return }

      var messages = changes.compactMap{ try? $0.document.data(as: Message.self) }

      for (index, message) in messages.enumerated() where message.fromId != currentUid {
        messages[index].user = self.user
      }

      self.messages.append(contentsOf: messages)
    }
  }
//    query.getDocuments { snapshot, error in
//      guard let documents = snapshot?.documents else { return }
//      var messages = documents.compactMap { try? $0.data(as: Message.self) }
//
//      print(self.messages)
//
//      for (index, message) in messages.enumerated() where message.fromId != currentUid {
//        messages[index].user = self.user
//      }
//    }

  func sendMessage(_ messageText: String) {
    guard let currentUid = UserService.shared.currentUser?.id else { return }
    let chatPartnerId = user.id
    
    let currentUserRef = FirestoreConstants.MessagesCollection.document(currentUid).collection(chatPartnerId).document()

    let chatPartnerRef = FirestoreConstants.MessagesCollection.document(chatPartnerId).collection(currentUid)

    let messageId = currentUserRef.documentID

    let data: [String : Any] = [
      "text" : messageText,
      "fromId" : currentUid,
      "toId" : chatPartnerId,
      "read" : false,
      "timestamp" : Timestamp(date: Date())
    ]

    currentUserRef.setData(data)
    chatPartnerRef.document(messageId).setData(data)
  }
}
