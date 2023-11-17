//
//  UserService.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/13/23.
//

import Firebase
import Foundation


class UserService: ObservableObject {

  static let shared = UserService()
  @Published var currentUser: User?
  @Published var profileImage: UIImage?

  private func mapUsers(fromSnapshot snapshot: QuerySnapshot) -> [User] {
    return snapshot.documents
      .compactMap({ try? $0.data(as: User.self) })
  }


  @MainActor
  func fetchCurrentUser() async throws {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    let snapshot = try await FirestoreConstants.UserCollection.document(uid).getDocument()
    let user = try snapshot.data(as: User.self)
    self.currentUser = user
  }

  //TODO: if .cache fails, try .server
  static func fetchUser(withUid uid: String, fromCache: Bool = true) async throws -> User {
    let snapshot = try await FirestoreConstants.UserCollection.document(uid).getDocument(source: fromCache ? .cache : .default) //TODO: snapshot listener to ensure data is being updated from server (quite sure this will only get the data from the server the first time)
    let user = try snapshot.data(as: User.self)                                                          // gets updated on app re-launch, unsure if/when it would get updated otherwise
    return user
  }

  static func fetchUser(withUid uid: String, completion: @escaping(User) -> Void) {
    FirestoreConstants.UserCollection.document(uid).getDocument { snapshot, _ in
      guard let user = try? snapshot?.data(as: User.self) else {
        print("DEBUG: Failed to map user")
        return
      }
      completion(user)
    }
  }

  static func fetchUsers(limit: Int? = nil) async throws -> [User] {
    guard let currentUid = Auth.auth().currentUser?.uid else { return [] }
    let query = FirestoreConstants.UserCollection

    if let limit {
      let snapshot = try await query.limit(to: limit).getDocuments()
      return mapUsers(fromSnapshot: snapshot, currentUid: currentUid)
    }

    let snapshot = try await query.getDocuments()
    return mapUsers(fromSnapshot: snapshot, currentUid: currentUid)
  }

  private static func mapUsers(fromSnapshot snapshot: QuerySnapshot, currentUid: String) -> [User] {
    return snapshot.documents
      .compactMap({ try? $0.data(as: User.self) })
      .filter({ $0.id !=  currentUid })
  }
}

// MARK: - Following

extension UserService {
  @MainActor
  static func follow(uid: String) async throws {
    guard let currentUid = Auth.auth().currentUser?.uid else { return }

    async let _ = try await FirestoreConstants
      .FollowingCollection
      .document(currentUid)
      .collection("user-following")
      .document(uid)
      .setData([:])

    async let _ = try await FirestoreConstants
      .FollowersCollection
      .document(uid)
      .collection("user-followers")
      .document(currentUid)
      .setData([:])

    async let _ = try await updateUserFeedAfterFollow(followedUid: uid)
  }

  @MainActor
  static func unfollow(uid: String) async throws {
    guard let currentUid = Auth.auth().currentUser?.uid else { return }

    async let _ = try await FirestoreConstants
      .FollowingCollection
      .document(currentUid)
      .collection("user-following")
      .document(uid)
      .delete()

    async let _ = try await FirestoreConstants
      .FollowersCollection
      .document(uid)
      .collection("user-followers")
      .document(currentUid)
      .delete()

    async let _ = try await updateUserFeedAfterUnfollow(unfollowedUid: uid)
  }

  static func checkIfUserIsFollowed(uid: String) async -> Bool {
    guard let currentUid = Auth.auth().currentUser?.uid else { return false }
    let collection = FirestoreConstants.FollowingCollection.document(currentUid).collection("user-following")
    guard let snapshot = try? await collection.document(uid).getDocument() else { return false }
    return snapshot.exists
  }
}

// MARK: - User Stats

extension UserService {
  //    static func fetchUserStats(uid: String) async throws -> UserStats { //TODO: bring this in
  //        async let followingSnapshot = try await FirestoreConstants.FollowingCollection.document(uid).collection("user-following").getDocuments()
  //        let following = try await followingSnapshot.count
  //
  //        async let followerSnapshot = try await FirestoreConstants.FollowersCollection.document(uid).collection("user-followers").getDocuments()
  //        let followers = try await followerSnapshot.count
  //
  //        async let postSnapshot = try await FirestoreConstants.PostsCollection.whereField("ownerUid", isEqualTo: uid).getDocuments()
  //        let posts = try await postSnapshot.count
  //
  //        return .init(following: following, posts: posts, followers: followers)
  //    }
}

// MARK: Feed Updates

extension UserService {
  static func updateUserFeedAfterFollow(followedUid: String) async throws {
    guard let currentUid = Auth.auth().currentUser?.uid else { return }
    let snapshot = try await FirestoreConstants
      .PostsCollection.whereField("ownerUid", isEqualTo: followedUid)
      .getDocuments()

    for document in snapshot.documents {
      try await FirestoreConstants
        .UserCollection
        .document(currentUid)
        .collection("user-feed")
        .document(document.documentID)
        .setData([:])
    }
  }

  static func updateUserFeedAfterUnfollow(unfollowedUid: String) async throws {
    guard let currentUid = Auth.auth().currentUser?.uid else { return }
    let snapshot = try await FirestoreConstants
      .PostsCollection.whereField("ownerUid", isEqualTo: unfollowedUid)
      .getDocuments()

    for document in snapshot.documents {
      try await FirestoreConstants
        .UserCollection
        .document(currentUid)
        .collection("user-feed")
        .document(document.documentID)
        .delete()
    }
  }
}

// MARK: Fetch User Following
extension UserService {

  static func fetchUserFollowing(uid: String) async throws -> [User] { //TODO: highest priority to update user cache
    async let snapshot = try await FirestoreConstants
      .FollowingCollection
      .document(uid)
      .collection("user-following")
      .getDocuments()


    var uids = [String]()
    for doc in try await snapshot.documents {
      uids.append(doc.documentID)
    }

    var following = [User]()
    for uid in uids {
      async let followee = try await UserService.fetchUser(withUid: uid, fromCache: false)
      try await following.append(followee)

    }
    return following
  }
}
