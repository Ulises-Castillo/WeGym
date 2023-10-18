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
  var name: String
  var profileImageUrl: String?
  var bio: String?
  
//  var isCurrentUser: Bool { //TODO: bring this back
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
    .init(id: NSUUID().uuidString, email: "uacastillo@ucdavis.edu", name: "Ulysses", profileImageUrl: nil, bio: "Amat Victoria Curam 💪"),
    .init(id: NSUUID().uuidString, email: "andrew@tate.com", name: "Andrew Emory Tate", profileImageUrl: nil, bio: "Escape the matrix"),
    .init(id: NSUUID().uuidString, email: "tristan@tate.com", name: "Tristan Tate", profileImageUrl: nil, bio: "International Playboy"),
    .init(id: NSUUID().uuidString, email: "steve@apple.com", name: "Steven Paul Jobs", profileImageUrl: nil, bio: "Find your passion, never settle"),
    .init(id: NSUUID().uuidString, email: "jordan@peterson.com", name: "Jordan B. Peterson", profileImageUrl: nil, bio: "12 Rules for Life"),
    .init(id: NSUUID().uuidString, email: "dan@pena.com", name: "Dan Pena", profileImageUrl: nil, bio: "Stop being soft"),
    .init(id: NSUUID().uuidString, email: "arnold@gym.com", name: "Arnold Schwarzenegger", profileImageUrl: nil, bio: "Have a vision"),
    .init(id: NSUUID().uuidString, email: "manny@boxing.com", name: "Manny Pacquiao", profileImageUrl: nil, bio: "Boxing is my life"),
  ]
  
  static var MOCK_USERS: [User] = [
    .init(id: NSUUID().uuidString, email: "uacastillo@ucdavis.edu", name: "Ulysses", profileImageUrl: "uly", bio: "Amat Victoria Curam 💪"),
    .init(id: NSUUID().uuidString, email: "andrew@tate.com", name: "Andrew", profileImageUrl: "andrew", bio: "Escape the matrix"),
    .init(id: NSUUID().uuidString, email: "tristan@tate.com", name: "Tristan", profileImageUrl: "tristan", bio: "International Playboy"),
    .init(id: NSUUID().uuidString, email: "steve@apple.com", name: "Steven", profileImageUrl: "steve", bio: "Find your passion, never settle"),
    .init(id: NSUUID().uuidString, email: "jordan@peterson.com", name: "Jordan", profileImageUrl: "jordan", bio: "12 Rules for Life"),
    .init(id: NSUUID().uuidString, email: "dan@pena.com", name: "Dan", profileImageUrl: "dan", bio: "Stop being soft"),
    .init(id: NSUUID().uuidString, email: "arnold@gym.com", name: "Arnold", profileImageUrl: "arnold", bio: "Have a vision"),
    .init(id: NSUUID().uuidString, email: "manny@boxing.com", name: "Manny", profileImageUrl: "manny", bio: "Boxing is my life"),
  ]
}
