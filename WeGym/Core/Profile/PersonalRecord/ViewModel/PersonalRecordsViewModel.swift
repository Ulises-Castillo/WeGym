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
