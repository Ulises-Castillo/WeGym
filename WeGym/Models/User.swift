//
//  User.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/13/23.
//

import Foundation
import Firebase

struct User: Identifiable, Hashable, Codable {
  let id: String
  let email: String
  var username: String // might make sense to be constant // q: does IG allow users to change username ?
  var fullName: String?
  var profileImageUrl: String?
  var bio: String?
  
  var isCurrentUser: Bool {
    guard let currentUid = Auth.auth().currentUser?.uid else { return false }
    return currentUid == id
  }
}


extension User {
  static var MOCK_USERS: [User] = [
    .init(id: NSUUID().uuidString, email: "uacastillo@ucdavis.edu", username: "master_ulysses", fullName: "Ulysses A. Castillo", profileImageUrl: "uly", bio: "Amat Victoria Curam 💪"),
    .init(id: NSUUID().uuidString, email: "andrew@tate.com", username: "cobra_tate", fullName: "Andrew Emory Tate", profileImageUrl: "andrew", bio: "Escape the matrix"),
    .init(id: NSUUID().uuidString, email: "tristan@tate.com", username: "talisman_tate", fullName: "Tristan Tate", profileImageUrl: "tristan", bio: "International Playboy"),
    .init(id: NSUUID().uuidString, email: "steve@apple.com", username: "steve_jobs", fullName: "Steven Paul Jobs", profileImageUrl: "steve", bio: "Find your passion, never settle"),
    .init(id: NSUUID().uuidString, email: "jordan@peterson.com", username: "jordan_peterson", fullName: "Jordan B. Peterson", profileImageUrl: "jordan", bio: "12 Rules for Life"),
    .init(id: NSUUID().uuidString, email: "dan@pena.com", username: "dan_pena", fullName: "Dan Pena", profileImageUrl: "dan", bio: "Stop being soft"),
    .init(id: NSUUID().uuidString, email: "arnold@gym.com", username: "arnold_s", fullName: "Arnold Schwarzenegger", profileImageUrl: "arnold", bio: "Have a vision"),
    .init(id: NSUUID().uuidString, email: "manny@boxing.com", username: "pacman", fullName: "Manny Pacquiao", profileImageUrl: "manny", bio: "Boxing is my life"),
  ]
}
