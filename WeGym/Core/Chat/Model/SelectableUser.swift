//
//  SelectableUser.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/25/23.
//

import Foundation

struct SelectableUser: Identifiable {
  let user: User
  var isSelected: Bool = true

  var id: String {
    return user.id
  }
}
