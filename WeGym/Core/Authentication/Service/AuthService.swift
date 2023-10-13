//
//  AuthService.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/13/23.
//

import Foundation
import FirebaseAuth

class AuthService {
  
  @Published var userSession: FirebaseAuth.User?
  
  static let shared = AuthService()
  
  init() {
    self.userSession = Auth.auth().currentUser
  }
  
  func login(withEmail email: String, password: String) async throws {
    
  }
  
  func createUser(email: String, password: String, username: String) async throws {
    print("Email is \(email)")
    print("Password is \(password)")
    print("Username is \(username)")
    
    do {
      let result = try await Auth.auth().createUser(withEmail: email, password: password)
      self.userSession = result.user
      print("userSession: \(String(describing: self.userSession))")
    } catch {
      print("DEBUG: Failed to register user with error: \(error.localizedDescription)")
    }
  }
  
  func loadUserData() async throws {
    
  }
  
  func signOut() {
    
  }
}
