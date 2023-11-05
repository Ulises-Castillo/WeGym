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
    }
  }

  init() {
    Task { try await observePersonalRecords() }
  }

  @Published var favoritePersonalRecordIds = [String]()

  func setFavorite(_ personalRecord: PersonalRecord) { //TODO: simplify by using fav array as single source of truth, add/remove from it, mark all as fav, all others non-fav

    //TODO: deal with unfavorite (personalRecord already contained in favs array)
    if personalRecordsCache[personalRecord.id]?.isFavorite ?? false {
      personalRecordsCache[personalRecord.id]?.isFavorite = false
      favoritePersonalRecordIds = favoritePersonalRecordIds.filter({ $0 != personalRecord.id })
      return
    }

    print("Fav PRs BEFORE: \(favoritePersonalRecordIds)")

    // 1. unfavorite any pr's in the same category, if any
    for i in 0..<favoritePersonalRecordIds.count {

      let id = favoritePersonalRecordIds[i]

      if personalRecordsCache[id]?.category == personalRecord.category &&
          personalRecordsCache[id]?.type == personalRecord.type {
        personalRecordsCache[id]?.isFavorite = false
        favoritePersonalRecordIds.remove(at: i) //TODO: check this, dangerous to remove during for loop // perhaps break right after
        break
      }
    }

    // 2. unfavorte oldest favorite PR if more than 2 favorite PRs
    while favoritePersonalRecordIds.count > 2 {
      personalRecordsCache[favoritePersonalRecordIds[0]]?.isFavorite = false
      favoritePersonalRecordIds.remove(at: 0)
    }

    // 3. set new favorite PRs array (size: 3)
    personalRecordsCache[personalRecord.id]?.isFavorite = true
    favoritePersonalRecordIds.append(personalRecord.id)


    print("Fav PRs AFTER: \(favoritePersonalRecordIds)")
    // 4. update DB
    //TODO: pr service set pr favorites: [String]
    // just 3 ids of the fav PRs
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
