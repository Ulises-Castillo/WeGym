//
//  ContentViewModel.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/13/23.
//

import Foundation
import Firebase
import Combine

class ContentViewModel: ObservableObject {
  
  
  private let service = AuthService.shared
  private var cancellables = Set<AnyCancellable>()
  
  @Published var userSession: FirebaseAuth.User?
  
  init() {
    
  }
  
  func setupSubscribers() {
    service.$userSession.sink { [weak self] userSession in
      self?.userSession = userSession
    }
    .store(in: &cancellables)
  }
}
