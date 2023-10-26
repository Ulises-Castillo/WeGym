//
//  SelectableUser.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/25/23.
//

import Foundation

struct SelectableUser: Identifiable, Decodable {
  let user: User
  var isSelected: Bool = false

  var id: String {
    return user.id
  }
}
