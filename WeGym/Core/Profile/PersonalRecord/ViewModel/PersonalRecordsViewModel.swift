//
//  PersonalRecordsViewModel.swift
//  WeGym
//
//  Created by Ulises Castillo on 11/4/23.
//

import Foundation

class PersonalRecordsViewModel: ObservableObject {

  @Published var personalRecords = [PersonalRecord]()
  @Published private var personalRecordsCache = [String: PersonalRecord]() {
    didSet {
      personalRecords = personalRecordsCache
        .values
        .sorted(by: {
          $0.timestamp.dateValue().timeIntervalSince1970 > $1.timestamp.dateValue().timeIntervalSince1970
        })

      favoritePersonalRecordIds = personalRecords.filter({ $0.isFavorite }).map({ $0.id })
      print("**** favoritePersonalRecordIds: \(favoritePersonalRecordIds)")
    }
  }

  init() {
    Task { try await observePersonalRecords() }
  }

  @Published var favoritePersonalRecordIds = [String]()

  @MainActor
  func setFavorite(_ personalRecord: PersonalRecord) { //TODO: clean up redundancy, simplify (use data stucture), separate unfav

    Task {
      //TODO: deal with unfavorite (personalRecord already contained in favs array)
      if personalRecordsCache[personalRecord.id]?.isFavorite ?? false {
        personalRecordsCache[personalRecord.id]?.isFavorite = false


        guard let updatedPr = personalRecordsCache[personalRecord.id] else { return }
        try await PersonalRecordService.updatePersonalRecord(updatedPr)
        try await PersonalRecordService.uploadFavoritePersonalRecordIds(favoritePersonalRecordIds)

        return
      }


      // 1. unfavorite any pr's in the same category, if any
      for (id, pr) in personalRecordsCache {
        if pr.isFavorite &&
            pr.category == personalRecord.category &&
            pr.type == personalRecord.type {
          personalRecordsCache[id]?.isFavorite = false


          guard let updatedPr = personalRecordsCache[id] else { return }
          try await PersonalRecordService.updatePersonalRecord(updatedPr)

          break
        }
      }

      // 2. unfavorte oldest favorite PR if more than 2 favorite PRs
      if favoritePersonalRecordIds.count > 2 {
        personalRecordsCache[favoritePersonalRecordIds[0]]?.isFavorite = false

        guard let updatedPr = personalRecordsCache[favoritePersonalRecordIds[0]] else { return }
        try await PersonalRecordService.updatePersonalRecord(updatedPr) //FIXME: removed PR not persisting on relaunch

      }

      // 3. set new favorite PRs array (size: 3)
      personalRecordsCache[personalRecord.id]?.isFavorite = true


      // 4. update DB

      try await PersonalRecordService.uploadFavoritePersonalRecordIds(favoritePersonalRecordIds)
      guard let updatePr = personalRecordsCache[personalRecord.id] else { return }
      try await PersonalRecordService.updatePersonalRecord(updatePr)

    }
  }

  @MainActor
  func observePersonalRecords() async throws {
    PersonalRecordService.observePersonalRecords { [weak self] personalRecords, removedPersonalRecords in
      guard let self = self else { return }

      for pr in removedPersonalRecords {
        personalRecordsCache[pr.id] = nil
      }

      for pr in personalRecords {
        personalRecordsCache[pr.id] = pr
      }
    }
  }

  @MainActor
  func addPersonalRecord(_ personalRecord: PersonalRecord) async throws {
    try await PersonalRecordService.uploadPersonalRecord(personalRecord)
  }

  @MainActor
  func deletePersonalRecord(_ personalRecord: PersonalRecord) async throws {
    try await PersonalRecordService.deletePersonalRecord(withId: personalRecord.id)
  }

  @MainActor
  func updatePersonalRecord(_ personalRecord: PersonalRecord) async throws {
    try await PersonalRecordService.updatePersonalRecord(personalRecord)
  }

  func removePersonalRecordListener() {
    PersonalRecordService.removeListener()
  }
}
