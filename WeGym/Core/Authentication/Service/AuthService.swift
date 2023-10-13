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
    userSession = Auth.auth().currentUser
  }
  
  @MainActor
  func login(withEmail email: String, password: String) async throws {
    do {
      let result = try await Auth.auth().signIn(withEmail: email, password: password)
      userSession = result.user
    } catch {
      print("DEBUG: Failed to log in user with error: \(error.localizedDescription)")
    }
  }
  
  @MainActor
  func createUser(email: String, password: String, username: String) async throws {
    do {
      let result = try await Auth.auth().createUser(withEmail: email, password: password)
      userSession = result.user
    } catch {
      print("DEBUG: Failed to register user with error: \(error.localizedDescription)")
    }
  }
  
  func loadUserData() async throws {
    
  }
  
  func signOut() {
    try? Auth.auth().signOut() //TODO: handle failure/optional
    userSession = nil
  }
}
