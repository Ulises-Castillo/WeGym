//
//  PersonalRecord.swift
//  WeGym
//
//  Created by Ulises Castillo on 11/4/23.
//

import Firebase

struct PersonalRecord: Identifiable, Hashable, Codable, Equatable {
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

extension PersonalRecord {
  static let MOCK_PERSONAL_RECORDS: [PersonalRecord] = [
    .init(id: NSUUID().uuidString,
          number: 245,
          category: "PowerLifting",
          type: "Bench",
          ownerUid: NSUUID().uuidString,
          timestamp: Timestamp(),
          notes: "These are my note for this PR"),

      .init(id: NSUUID().uuidString,
            number: 315,
            category: "PowerLifting",
            type: "Squat",
            ownerUid: NSUUID().uuidString,
            timestamp: Timestamp(),
            notes: "These are my note for this PR"),
    
      .init(id: NSUUID().uuidString,
            number: 365,
            category: "PowerLifting",
            type: "Deadlift",
            ownerUid: NSUUID().uuidString,
            timestamp: Timestamp(date: Date.now.addingTimeInterval(-9000)),
            notes: "These are my note for this PR"),

      .init(id: NSUUID().uuidString,
            number: 225,
            category: "PowerLifting",
            type: "Bench",
            ownerUid: NSUUID().uuidString,
            timestamp: Timestamp(date: Date.now.addingTimeInterval(-16000)),
            notes: "These are my note for this PR"),

      .init(id: NSUUID().uuidString,
            number: 295,
            category: "PowerLifting",
            type: "Squat",
            ownerUid: NSUUID().uuidString,
            timestamp: Timestamp(date: Date.now.addingTimeInterval(-32000)),
            notes: "These are my note for this PR"),

      .init(id: NSUUID().uuidString,
            number: 315,
            category: "PowerLifting",
            type: "Deadlift",
            ownerUid: NSUUID().uuidString,
            timestamp: Timestamp(date: Date.now.addingTimeInterval(-62000)),
            notes: "These are my note for this PR"),

      .init(id: NSUUID().uuidString,
            number: 205,
            category: "PowerLifting",
            type: "Bench",
            ownerUid: NSUUID().uuidString,
            timestamp: Timestamp(date: Date.now.addingTimeInterval(-81000)),
            notes: "These are my note for this PR"),

      .init(id: NSUUID().uuidString,
            number: 205,
            category: "PowerLifting",
            type: "Squat",
            ownerUid: NSUUID().uuidString,
            timestamp: Timestamp(date: Date.now.addingTimeInterval(-93000)),
            notes: "These are my note for this PR"),

      .init(id: NSUUID().uuidString,
            number: 295,
            category: "PowerLifting",
            type: "Deadlift",
            ownerUid: NSUUID().uuidString,
            timestamp: Timestamp(date: Date.now.addingTimeInterval(-108000)),
            notes: "These are my note for this PR"),

      .init(id: NSUUID().uuidString,
            number: 185,
            category: "PowerLifting",
            type: "Squat",
            ownerUid: NSUUID().uuidString,
            timestamp: Timestamp(date: Date.now.addingTimeInterval(-505000)),
            notes: "These are my note for this PR"),

      .init(id: NSUUID().uuidString,
            number: 185,
            category: "PowerLifting",
            type: "Bench",
            ownerUid: NSUUID().uuidString,
            timestamp: Timestamp(date: Date.now.addingTimeInterval(-900000)),
            notes: "These are my note for this PR"),
  ]
}
