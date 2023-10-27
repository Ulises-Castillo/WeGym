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
  @ObservedObject var current = UserService.shared

  @Published var selectedImage: PhotosPickerItem? {
    didSet { Task { await loadImage(fromItem: selectedImage) } }
  }
  
  @Published var profileImage: Image?
  
  @Published var fullName = ""
  @Published var bio = ""

  @Published var updatedImageURL: String?

  private var uiImage: UIImage?
  
  init() {
    if let fullName = current.currentUser?.fullName {
      self.fullName = fullName
    }
    
    if let bio = current.currentUser?.bio {
      self.bio = bio
    }
  }
  
  func loadImage(fromItem item: PhotosPickerItem?) async {
    guard let item = item else { return }
    
    guard let data = try? await item.loadTransferable(type: Data.self) else { return }
    guard let uiImage = UIImage(data: data) else { return }
    self.uiImage = uiImage
    profileImage = Image(uiImage: uiImage)
  }

  func updateUserData() async throws {
    // update profile image if changed
    var data = [String: Any]()
    
    if let uiImage = uiImage {
      let imageUrl = try await ImageUploader.uploadImage(image: uiImage)
      data["profileImageUrl"] = imageUrl
      updatedImageURL = imageUrl
    }
    
    // update name if changed
    if !fullName.isEmpty && current.currentUser?.fullName != fullName {
      data["fullName"] = fullName // fullName ?
    }
    
    // update bio if changed
    if !bio.isEmpty && current.currentUser?.bio != bio {
      data["bio"] = bio
    }
    
    if !data.isEmpty {
      try await Firestore.firestore().collection("users").document(current.currentUser!.id).updateData(data)
    }
  }
}

