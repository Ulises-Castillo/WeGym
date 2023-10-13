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
    
  }
  
  func loadUserData() async throws {
    
  }
  
  func signOut() {
    
  }
}
