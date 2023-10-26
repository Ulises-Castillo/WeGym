//
//  Channel.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/26/23.
//

import FirebaseFirestoreSwift

struct Channel: Identifiable, Decodable {
  @DocumentID var id: String?
  let name: String
  let imageUrl: String?
  let uids: [String] //TODO: add ability to add / remove members from group chat, also name, etc.
  var lastMessage: String
}
