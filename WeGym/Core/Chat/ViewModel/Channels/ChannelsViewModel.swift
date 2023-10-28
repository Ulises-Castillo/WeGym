//
//  ChannelsViewModel.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/26/23.
//

import Foundation

@MainActor
class ChannelsViewModel: ObservableObject {
  @Published var channels = [Channel] ()
  
  init() {
    Task { try await fetchChannels() }
  }
  
  func fetchChannels() async throws {
    guard let uid = UserService.shared.currentUser?.id else { return }
    
    let docs = try await FirestoreConstants.ChannelsCollection.whereField("uids", arrayContains: uid).getDocuments()
    self.channels = docs.documents.compactMap({ try? $0.data(as: Channel.self) })
  }
}
