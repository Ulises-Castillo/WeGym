//
//  SearchViewModel.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/13/23.
//

import Foundation

class SearchViewModel: ObservableObject {
  @Published var users = [User]()
  
  init() {
    Task { try await fetchAllUsers() }
  }
  
  @MainActor
  func fetchAllUsers() async throws {
    users = try await UserService.fetchAllUsers()
  }
}
