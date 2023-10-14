//
//  Post.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/13/23.
//

import Foundation
import Firebase

struct Post: Identifiable, Hashable, Codable {
  let id: String
  let ownwerUid: String
  let caption: String
  var likes: Int
  let imageUrl: String
  let timestamp: Timestamp
  var user: User?
}

extension Post {
  static var MOCK_POSTS: [Post] = [
    
    .init(
      id: NSUUID().uuidString,
      ownwerUid: NSUUID().uuidString,
      caption: "Amat Victoria Curam 💪",
      likes: 3000,
      imageUrl: "smoke",
      timestamp: Timestamp(),
      user: User.MOCK_USERS[0]
    ),
      .init(
        id: NSUUID().uuidString,
        ownwerUid: NSUUID().uuidString,
        caption: "Resist the Slave Mind 🧠",
        likes: 555,
        imageUrl: "andrew",
        timestamp: Timestamp(),
        user: User.MOCK_USERS[1]
      ),
    .init(
      id: NSUUID().uuidString,
      ownwerUid: NSUUID().uuidString,
      caption: "Dress in suits",
      likes: 101,
      imageUrl: "tristan",
      timestamp: Timestamp(),
      user: User.MOCK_USERS[2]
    ),
    .init(
      id: NSUUID().uuidString,
      ownwerUid: NSUUID().uuidString,
      caption: "Greatest man ever from Palo Alto",
      likes: 3000,
      imageUrl: "steve",
      timestamp: Timestamp(),
      user: User.MOCK_USERS[3]
    ),
    .init(
      id: NSUUID().uuidString,
      ownwerUid: NSUUID().uuidString,
      caption: "You could be more than you are and you know it",
      likes: 99,
      imageUrl: "jordan",
      timestamp: Timestamp(),
      user: User.MOCK_USERS[4]
    ),
    .init(
      id: NSUUID().uuidString,
      ownwerUid: NSUUID().uuidString,
      caption: "Show me your friends and I'll show you your future",
      likes: 99,
      imageUrl: "dan",
      timestamp: Timestamp(),
      user: User.MOCK_USERS[5]
    ),
    .init(
      id: NSUUID().uuidString,
      ownwerUid: NSUUID().uuidString,
      caption: "I will do whatever it takes to become a champion",
      likes: 345,
      imageUrl: "arnold",
      timestamp: Timestamp(),
      user: User.MOCK_USERS[6]
    ),
    .init(
      id: NSUUID().uuidString,
      ownwerUid: NSUUID().uuidString,
      caption: "Boxing is my life !",
      likes: 432,
      imageUrl: "manny",
      timestamp: Timestamp(),
      user: User.MOCK_USERS[7]
    ),
  ]
}
