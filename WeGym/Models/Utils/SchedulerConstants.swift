//
//  SchedulerConstants.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/22/23.
//

import Foundation


struct SchedulerConstants {
  static let workoutCategoryFocusesMap: [String: [String]] = [
    "BRO":   [
      "Chest",
      "Back",
      "Shoulders",
      "Legs",
      "Arms"
    ],
    "PPL":   [
      "Push",
      "Pull",
      "Legs"
    ],
    "PWR":   [
      "SBD",
      "Squat",
      "Bench",
      "Deadlift",
      "Accesories"
    ],
    "FUL":   [
      "Full Body",
      "Upper Body",
      "Lower Body"
    ],
    "ISO":   [
      "Abs",
      "Biceps",
      "Triceps",
      "Forearms",
      "Glutes",
      "Quads",
      "Hams",
      "Calves",
      "Front Delts",
      "Side Delts",
      "Rear Delts",
      "Lats",
      "Lower Back",
      "Traps"
    ],
    "CTX":   [
      "Pull Ups",
      "Muscle Ups",
      "Dips"
    ],
    "BOX":   [
      "Roadwork",
      "Padwork",
      "Bagwork",
      "Sparring",
      "Shadowboxing"
    ],
    "MSC":   [
      "Cardio",
      "Stretch",
      "Yoga",
      "Dance"
    ],
  ]
}

let dummyId = "rest_day"
