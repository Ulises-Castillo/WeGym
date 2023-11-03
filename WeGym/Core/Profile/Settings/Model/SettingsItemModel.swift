//
//  SettingsItemModel.swift
//  WeGym
//
//  Created by Ulises Castillo on 11/3/23.
//

import Foundation

enum SettingsItemModel: Int, Identifiable, Hashable, CaseIterable {
  case settings
  case yourActivity
  case saved
  case logout
  
  var title: String {
    switch self {
    case .settings:
      return "Settings"
    case .yourActivity:
      return "Your Activity"
    case .saved:
      return "Saved"
    case .logout:
      return "Logout"
    }
  }
  
  var imageName: String {
    switch self {
    case .settings:
      return "gear"
    case .yourActivity:
      return "cursorarrow.click.badge.clock"
    case .saved:
      return "bookmark"
    case .logout:
      return "x.square"
    }
  }
  
  var id: Int { return self.rawValue }
}
