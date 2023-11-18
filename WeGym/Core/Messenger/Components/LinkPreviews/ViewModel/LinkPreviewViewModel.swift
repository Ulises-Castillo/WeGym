//
//  LinkPreviewViewModel.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/26/23.
//

import LinkPresentation
import UniformTypeIdentifiers
import SwiftUI

@MainActor
class LinkPreviewViewModel: ObservableObject {
  let metadataProvider = LPMetadataProvider()
  
  @Published var metadata: LPLinkMetadata?
  @Published var image: Image?
  
  init(urlString: String) {
    
    Task { try await fetchLinkMetadata(urlString: urlString) }
  }
  
  private func fetchLinkMetadata(urlString: String)  async throws {
    var urlString = urlString

    if !urlString.hasPrefix("http") {
      urlString = "https://" + urlString
    }
    guard let url = URL(string: urlString) else { return }
    
    let metadata = try await metadataProvider.startFetchingMetadata(for: url)
    self.metadata = metadata
    
    guard let imageProvider = metadata.imageProvider else { return }
    guard let imageData = try await imageProvider.loadItem(forTypeIdentifier: UTType.image.identifier) as? Data else { return }
    
    guard let uiImage = UIImage(data: imageData) else { return }
    self.image = Image(uiImage: uiImage)
  }
}

