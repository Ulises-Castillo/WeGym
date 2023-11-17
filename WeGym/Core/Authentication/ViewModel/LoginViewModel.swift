//
//  LoginViewModel.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/13/23.
//

import Foundation

class LoginViewModel: ObservableObject {
  @Published var email = ""
  @Published var password = ""

  func signIn() async throws {

    // Detect username
    if !email.contains("@") {
      let username = email

      // fetch user by username
      let snapshot = try await FirestoreConstants
        .UserCollection
        .whereField("username", isEqualTo: username)
        .getDocuments()

      guard let user = snapshot.documents.compactMap({ try? $0.data(as: User.self) }).first else {
        print("DEBUG: username login failed: no username |\(username)| exists")
        return
      }

      // login with email
      try await AuthService.shared.login(withEmail: user.email, password: password)
    } else {
      try await AuthService.shared.login(withEmail: email, password: password)
    }
  }
}
