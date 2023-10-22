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
}
