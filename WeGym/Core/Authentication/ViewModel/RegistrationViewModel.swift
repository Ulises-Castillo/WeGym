//
//  RegistrationViewModel.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/13/23.
//

import Foundation

class RegistrationViewModel: ObservableObject {
  
  @Published var username = ""
  @Published var email = ""
  @Published var password = ""
  
  
  @MainActor
  func createUser() async throws {
    try await AuthService.shared.createUser(email: email.lowercased(),
                                            password: password,
                                            username: username.lowercased())
    
    username = ""
    email = ""
    password = ""
  }
}
