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


extension TrainingSession {
  static let MOCK_TRAINING_SESSIONS: [TrainingSession] = [
    .init(id: NSUUID().uuidString,
          date: Date.now.addingTimeInterval(2000),
          focus: ["Chest", "Back", "Abs"],
          location: "Redwood City 24",
          caption: "Going for a bench PR today! 💪",
          user: User.MOCK_USERS[0]),
    
      .init(id: NSUUID().uuidString,
            date: Date.now.addingTimeInterval(4000),
            focus: ["Back", "Biceps"],
            location: "Bucharest 24",
            caption: "Believe it or not I'm 💯% natty bruv",
            user: User.MOCK_USERS[2]),
    
      .init(id: NSUUID().uuidString,
            date: Date.now.addingTimeInterval(600),
            focus: ["Full Body"],
            location: "Toronto University Gym",
            caption: "",
            user: User.MOCK_USERS[4]),
    
      .init(id: NSUUID().uuidString,
            date: Date.now.addingTimeInterval(1000),
            focus: ["Squat", "Bench", "Deadlift"],
            location: "Guithre Castle Gym",
            caption: "Show me your friends, and I'll show your future.",
            user: User.MOCK_USERS[5]),
    
      .init(id: NSUUID().uuidString,
            date: Date.now.addingTimeInterval(6000),
            focus: ["Cardio"],
            location: "Palo Alto Equinox",
            caption: "Follow your passion and NEVER settle.",
            user: User.MOCK_USERS[3]),
    
      .init(id: NSUUID().uuidString,
            date: Date.now.addingTimeInterval(200),
            focus: ["Legs"],
            location: "Bucharest 24",
            caption: "Will finally sqat 315 for 6 reps 🦵",
            user: User.MOCK_USERS[1]),
    
      .init(id: NSUUID().uuidString,
            date: Date.now.addingTimeInterval(50),
            focus: ["Arms", "Shoulders"],
            location: "Venice Beach Gold's Gym",
            caption: "Have a vision and never give up! 🏆",
            user: User.MOCK_USERS[6]),
    
      .init(id: NSUUID().uuidString,
            date: Date(),
            focus: ["Padwork", "Sparring"],
            location: "Wildcard Gym",
            caption: "Boxing is my life! 🥊",
            user: User.MOCK_USERS[7]),
  ]
}
