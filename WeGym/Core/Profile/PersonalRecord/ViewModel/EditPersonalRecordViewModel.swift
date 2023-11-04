//
//  EditPersonalRecordViewModel.swift
//  WeGym
//
//  Created by Ulises Castillo on 11/3/23.
//

import Foundation

class EditPersonalRecordViewModel: ObservableObject {

  //TODO: should be ordered by most recently accessed (Corey should see "PWR" already selected)
  // This will be passed in from the backend, the the `workouts` dictionary will be constructed dynamically w/ loop
  @Published var personalRecordCategories = ["Powerlifting", "Body Building", "Calesthenics"]
  @Published var selectedPersonalRecordCategory = [String]()

  let prCategoryMap: [String: [String]]  = [
    "Powerlifting": [
      "Squat",
      "Bench",
      "Deadlift",
    ],
    "Body Building": [
      "Bicep Curl",
      "Hack Squat",
      "Incline Bench",
      "Dumbell Bench",
    ],
    "Calesthenics": [
      "Pull ups",
      "Dips",
      "Muscle ups"
    ]
  ]

  @Published var personalRecordTypes: [String] = []
  @Published var selectedPersonalRecordType = [String]()
}
