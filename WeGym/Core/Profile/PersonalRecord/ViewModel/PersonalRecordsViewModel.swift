//
//  PersonalRecordsViewModel.swift
//  WeGym
//
//  Created by Ulises Castillo on 11/4/23.
//

import Foundation

class PersonalRecordsViewModel: ObservableObject {

  @Published var personalRecords = [PersonalRecord]()
  @Published var personalRecordsCache = [String: PersonalRecord]() {
    didSet {
      personalRecords = personalRecordsCache
        .values
        .filter({ $0.ownerUid == UserService.shared.currentUser?.id })
        .sorted(by: {
          $0.timestamp.dateValue().timeIntervalSince1970 > $1.timestamp.dateValue().timeIntervalSince1970
        })
    }
  }

  init() {
    Task { try await observePersonalRecords() }
  }

  @MainActor
  func observePersonalRecords() async throws {
    PersonalRecordService.observePersonalRecords { [weak self] personalRecords, removedPersonalRecords in
      guard let self = self else { return }

      for pr in removedPersonalRecords {    //TODO: if a category max is removed must determine new category max
        personalRecordsCache[pr.id] = nil
      }

      for pr in personalRecords {
        personalRecordsCache[pr.id] = pr
      }

      categoryMaxMap.removeAll()
      for pr in personalRecordsCache.values {
        checkCategoryMax(pr: pr)
      }
    }
  }

  @MainActor
  func addPersonalRecord(_ personalRecord: PersonalRecord, trainingSession: TrainingSession?) async throws {
    try await PersonalRecordService.uploadPersonalRecord(personalRecord, trainingSession: trainingSession)
  }

  @MainActor
  func deletePersonalRecord(_ personalRecord: PersonalRecord, _ trainingSession: TrainingSession?) async throws {
    try await PersonalRecordService.deletePersonalRecord(withId: personalRecord.id, trainingSession)
  }

  @MainActor
  func updatePersonalRecord(_ personalRecord: PersonalRecord) async throws {
    try await PersonalRecordService.updatePersonalRecord(personalRecord)
  }

  func removePersonalRecordListener() {
    PersonalRecordService.removeListener()
  }

  //              Key: "Bench" : PR(weight, reps, date)
  var categoryMaxMap = [String: PersonalRecord]()

  func isCategoryMax(pr: PersonalRecord) -> Bool {  // simple bool test to determine whether to display bold text
    return categoryMaxMap[pr.type]?.id == pr.id     // (no need for property on model)
  }

  func checkCategoryMax(pr: PersonalRecord) { //TODO: just roll through the entire array when set looking for new Category max
    guard let currentMax = categoryMaxMap[pr.type] else { // no current max, just set new max
      categoryMaxMap[pr.type] = pr
      return
    }

    if pr.category == "Calesthenics" {
      guard let newReps = pr.reps, let currentReps = currentMax.reps else { return }
      if newReps > currentReps {
        categoryMaxMap[pr.type] = pr
      } else if newReps == currentReps && pr.timestamp.dateValue().timeIntervalSince1970 < currentMax.timestamp.dateValue().timeIntervalSince1970 {
        categoryMaxMap[pr.type] = pr
      }
      return
    }

    //TODO: deal with Calethenics separately first
    guard let newWeight = pr.weight, let currentWeight = currentMax.weight else { return }

    if newWeight > currentWeight {    // heavier weight
      categoryMaxMap[pr.type] = pr
    } else if let newReps = pr.reps, let currentReps = currentMax.reps {
      if newWeight == currentWeight { // same weight
        if newReps > currentReps {    // more reps
          categoryMaxMap[pr.type] = pr
        } else if newReps == currentReps && pr.timestamp.dateValue().timeIntervalSince1970 < currentMax.timestamp.dateValue().timeIntervalSince1970 { // older (original) PR
          categoryMaxMap[pr.type] = pr
        }
      }
    }
  }
}
