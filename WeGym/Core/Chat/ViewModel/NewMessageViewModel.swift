//
//  NewMessageViewModel.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/24/23.
//

import SwiftUI
import Firebase

class NewMessageViewModel: ObservableObject {
  @Published var users = [User]()

  init() {
    fetchUsers()
  }

  func fetchUsers() {
    FirestoreConstants.UserCollection.getDocuments { snapshot, _ in
      guard let documents = snapshot?.documents else { return }
      self.users = documents.compactMap({ try? $0.data(as: User.self) })

      print("DEBUG: Users \(self.users)")
    }
  }
}
