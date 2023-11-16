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
  
  @Published var emailIsValid = false
  @Published var usernameIsValid = false
  @Published var isLoading = false
  
  @Published var emailValidationFailed = false
  @Published var usernameValidationFailed = false
  
  
  @MainActor
  func createUser() async throws {
    try await AuthService.shared.createUser(email: email.lowercased(),
                                            password: password,
                                            username: username.lowercased())
    
    username = ""
    email = ""
    password = ""
  }
  
  @MainActor
  func validateEmail() async throws {
    self.isLoading = true
    self.emailValidationFailed = false
    
    let snapshot = try await FirestoreConstants
      .UserCollection
      .whereField("email", isEqualTo: email)
      .getDocuments()
    
    self.emailValidationFailed = !snapshot.isEmpty
    self.emailIsValid = snapshot.isEmpty
    
    self.isLoading = false
  }
  
  @MainActor
  func validateUsername() async throws {
    self.isLoading = true
    
    let snapshot = try await FirestoreConstants
      .UserCollection
      .whereField("username", isEqualTo: username)
      .getDocuments()
    
    self.usernameValidationFailed = !snapshot.isEmpty
    self.usernameIsValid = snapshot.isEmpty
    self.isLoading = false
  }
}
