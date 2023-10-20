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
  var isFollowed: Bool? = false

//  var isCurrentUser: Bool {
//    guard let currentUid = Auth.auth().currentUser?.uid else { return false }
//    return currentUid == id
//  }
  
  var isCurrentUser: Bool { //FIXME: should user id above; for Testing only
    guard let currentEmail = Auth.auth().currentUser?.email else { return false }
    return currentEmail == email
  }
}


extension User {
  static var MOCK_USERS_2: [User] = [
    .init(id: NSUUID().uuidString, email: "uacastillo@ucdavis.edu", username: "master_ulysses", fullName: "Ulysses", profileImageUrl: nil, bio: "Amat Victoria Curam 💪"),
    .init(id: NSUUID().uuidString, email: "andrew@tate.com", username: "cobra_tate", fullName: "Andrew Emory Tate", profileImageUrl: nil, bio: "Escape the matrix"),
    .init(id: NSUUID().uuidString, email: "tristan@tate.com", username: "talisman_tate", fullName: "Tristan Tate", profileImageUrl: nil, bio: "International Playboy"),
    .init(id: NSUUID().uuidString, email: "steve@apple.com", username: "steve_jobs", fullName: "Steven Paul Jobs", profileImageUrl: nil, bio: "Find your passion, never settle"),
    .init(id: NSUUID().uuidString, email: "jordan@peterson.com", username: "jordan_peterson", fullName: "Jordan B. Peterson", profileImageUrl: nil, bio: "12 Rules for Life"),
    .init(id: NSUUID().uuidString, email: "dan@pena.com", username: "dan_pena", fullName: "Dan Pena", profileImageUrl: nil, bio: "Stop being soft"),
    .init(id: NSUUID().uuidString, email: "arnold@gym.com", username: "arnold_s", fullName: "Arnold Schwarzenegger", profileImageUrl: nil, bio: "Have a vision"),
    .init(id: NSUUID().uuidString, email: "manny@boxing.com", username: "pacman", fullName: "Manny Pacquiao", profileImageUrl: nil, bio: "Boxing is my life"),
  ]
  
  static var MOCK_USERS: [User] = [
    .init(id: NSUUID().uuidString, email: "uacastillo@ucdavis.edu", username: "master_ulysses", fullName: "Ulysses", profileImageUrl: "uly", bio: "Amat Victoria Curam 💪"),
    .init(id: NSUUID().uuidString, email: "andrew@tate.com", username: "cobra_tate", fullName: "Andrew", profileImageUrl: "andrew", bio: "Escape the matrix"),
    .init(id: NSUUID().uuidString, email: "tristan@tate.com", username: "talisman_tate", fullName: "Tristan", profileImageUrl: "tristan", bio: "International Playboy"),
    .init(id: NSUUID().uuidString, email: "steve@apple.com", username: "steve_jobs", fullName: "Steven", profileImageUrl: "steve", bio: "Find your passion, never settle"),
    .init(id: NSUUID().uuidString, email: "jordan@peterson.com", username: "jordan_peterson", fullName: "Jordan", profileImageUrl: "jordan", bio: "12 Rules for Life"),
    .init(id: NSUUID().uuidString, email: "dan@pena.com", username: "dan_pena", fullName: "Dan", profileImageUrl: "dan", bio: "Stop being soft"),
    .init(id: NSUUID().uuidString, email: "arnold@gym.com", username: "arnold_s", fullName: "Arnold", profileImageUrl: "arnold", bio: "Have a vision"),
    .init(id: NSUUID().uuidString, email: "manny@boxing.com", username: "pacman", fullName: "Manny", profileImageUrl: "manny", bio: "Boxing is my life"),
  ]
}
