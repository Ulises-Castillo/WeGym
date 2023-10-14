//
//  AuthService.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/13/23.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift

class AuthService {
  
  @Published var userSession: FirebaseAuth.User?
  @Published var currentUser: User?
  
  static let shared = AuthService()
  
  init() {
    Task { try await loadUserData() }
  }
  
  @MainActor
  func login(withEmail email: String, password: String) async throws {
    do {
      let result = try await Auth.auth().signIn(withEmail: email, password: password)
      userSession = result.user
      try await loadUserData()
    } catch {
      print("DEBUG: Failed to log in user with error: \(error.localizedDescription)")
    }
  }
  
  @MainActor
  func createUser(email: String, password: String, username: String) async throws {
    do {
      let result = try await Auth.auth().createUser(withEmail: email, password: password)
      userSession = result.user
      await uploadUserData(uid: result.user.uid, username: username, email: email)
      
    } catch {
      print("DEBUG: Failed to register user with error: \(error.localizedDescription)")  //TODO: add debug logger
    }
  }
  
  @MainActor
  func loadUserData() async throws {
    userSession = Auth.auth().currentUser
    guard let currentUid = userSession?.uid else { return }
    let snapshot = try await Firestore.firestore().collection("users").document(currentUid).getDocument()
    currentUser = try? snapshot.data(as: User.self)
  }
  
  func signOut() {
    try? Auth.auth().signOut() //TODO: handle failure/optional
    userSession = nil
    currentUser = nil
  }
  
  private func uploadUserData(uid: String, username: String, email: String) async {
    let user = User(id: uid, email: email, username: username)
    currentUser = user
    guard let encodedUser = try? Firestore.Encoder().encode(user) else { return }
    //FIXME: don't hardcode "users" path string // separate file with constants
    try? await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
  }
}
