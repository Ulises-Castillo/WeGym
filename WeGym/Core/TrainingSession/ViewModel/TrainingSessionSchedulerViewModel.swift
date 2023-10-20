//
//  TrainingSessionSchedulerViewModel.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/19/23.
//

import Foundation

class TrainingSessionSchedulerViewModel: ObservableObject {
  
  //TODO: should be ordered by most recently accessed (Corey should see "PWR" already selected)
  // This will be passed in from the backend, the the `workouts` dictionary will be constructed dynamically w/ loop
  @Published var workoutCategories = ["BRO", "PPL", "PWR", "FUL", "ISO", "CTX", "BOX", "MSC"]
  @Published var selectedWorkoutCategory = [String]()
  
  @Published var workoutFocuses: [String] = []
  @Published var selectedWorkoutFocuses = [String]()
  
  @Published var gyms: [String] = [
    "Redwood City 24",
    "San Carlos 24",
    "Mountain View 24",
    "Vallejo In-Shape"
  ]
  @Published var selectedGym = [String]()
  
  @Published var workoutCategoryFocusesMap: [String: [String]] = [
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
      "Abs",
      "Cardio"
    ],
  ]
}
