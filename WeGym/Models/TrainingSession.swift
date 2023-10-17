//
//  TrainingSession.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/16/23.
//

import Foundation

struct TrainingSession: Identifiable, Hashable, Codable {
  let id: String
  var date: Date
  var focus: [String]   // disable submit button (green check unless focus selected)
  var location: String? // optional, user may choose not to share location
  var caption: String?
  var user: User?       // left optional for same reason as Post data model
//  var broLimit: Int?  //TODO: not part of MVP
//  var weekly: Bool = false
}
