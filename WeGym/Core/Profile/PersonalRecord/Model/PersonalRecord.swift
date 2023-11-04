//
//  PersonalRecord.swift
//  WeGym
//
//  Created by Ulises Castillo on 11/4/23.
//

import Firebase

struct PersonalRecord: Identifiable, Hashable, Codable {
  let id: String
  var number: Int
  var category: String
  var type: String
  let ownerUid: String
  let timestamp: Timestamp
  var notes: String
  var isFavorite = false
  var isCategoryMax = false
}
