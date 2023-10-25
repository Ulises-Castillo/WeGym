//
//  Message.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/24/23.
//

import Foundation

struct Message: Identifiable {
  let id = NSUUID().uuidString
  let isFromCurrentUser: Bool
  let messageText: String
}
