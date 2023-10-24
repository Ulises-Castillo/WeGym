//
//  DeveloperPreview.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/23/23.
//

import SwiftUI
import Firebase

extension PreviewProvider {
  static var dev: DeveloperPreview {
    return DeveloperPreview.shared
  }
}


class DeveloperPreview {
  static let shared = DeveloperPreview()

  let comment = Comment(trainingSessionOwnerUid: "1234", commentText: "Test comment for now", trainingSessionId: "3421", timestamp: Timestamp(), commentOwnerUid: "1234")
}
