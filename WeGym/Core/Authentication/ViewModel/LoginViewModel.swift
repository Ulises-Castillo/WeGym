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
    try await AuthService.shared.login(withEmail: email, password: password)
  }
}
