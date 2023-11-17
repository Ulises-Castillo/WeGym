//
//  FirestoreConstants.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/19/23.
//

import Foundation

import Firebase

struct FirestoreConstants {
  private static let Root = Firestore.firestore()
  
  static let UserCollection = Root.collection("users")
  
  static let PostsCollection = Root.collection("posts")
  
  static let TrainingSessionsCollection = Root.collection("training_sessions")
  static let PersonalRecordsCollection = Root.collection("personal_records")

  static let FollowersCollection = Root.collection("followers")
  static let FollowingCollection = Root.collection("following")
  
  static let NotificationsCollection = Root.collection("notifications")
  
  static let MessagesCollection = Root.collection("messages")
  
  static let ChannelsCollection = Root.collection("channels")

  static let UserMetaCollection = Root.collection("user_meta")
}
