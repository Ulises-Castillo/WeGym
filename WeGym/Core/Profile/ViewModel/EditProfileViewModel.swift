//
//  EditProfileViewModel.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/13/23.
//

import SwiftUI
import PhotosUI
import Firebase

@MainActor
class EditProfileViewModel: ObservableObject {
  @Published var selectedImage: PhotosPickerItem? {
    didSet { Task { await loadImage(fromItem: selectedImage) } }
  }
  
  @Published var profileImage: Image?
  
  @Published var fullName = ""
  @Published var bio = ""
  
  func loadImage(fromItem item: PhotosPickerItem?) async {
    guard let item = item else { return }
    
    guard let data = try? await item.loadTransferable(type: Data.self) else { return }
    guard let uiImage = UIImage(data: data) else { return }
    profileImage = Image(uiImage: uiImage)
  }
}
