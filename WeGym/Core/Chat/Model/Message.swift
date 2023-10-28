//
//  Message.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/24/23.
//

import Firebase
import FirebaseFirestoreSwift

struct Message2: Identifiable, Decodable {
  @DocumentID var id: String?
  let fromId: String
  let toId: String
  let read: Bool
  let text: String
  let timestamp: Timestamp

  var user: User?
}
