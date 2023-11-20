//
//  TrainingSessionSchedulerViewModel.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/19/23.
//

import SwiftUI
import PhotosUI
import Firebase

@MainActor
class TrainingSessionSchedulerViewModel: ObservableObject {
  
  //TODO: should be ordered by most recently accessed (Corey should see "PWR" already selected)
  // This will be passed in from the backend, the the `workouts` dictionary will be constructed dynamically w/ loop
  @Published var workoutCategories = ["BRO", "PPL", "PWR", "FUL", "ISO", "CTX", "BOX", "MSC"]
  @Published var selectedWorkoutCategory = [String]()
  
  @Published var workoutFocuses: [String] = []
  @Published var selectedWorkoutFocuses = [String]()

  @Published var gyms: [String] = [
    "Redwood City 24",
    "San Carlos 24",
    "Mountain View 24",
    "Vallejo In-Shape"
  ]
  @Published var selectedGym = [String]()

  private var uiImage: UIImage?

  @Published var updatedImageURL: String?
  @Published var image: Image?
  @Published var selectedImage: PhotosPickerItem? {
    didSet { Task { await loadImage(fromItem: selectedImage) } }
  }
  
  func loadImage(fromItem item: PhotosPickerItem?) async {
    guard let item = item else { return }
    
    guard let data = try? await item.loadTransferable(type: Data.self) else { return }
    guard let uiImage = UIImage(data: data) else { return }
//    UserService.shared.profileImage = uiImage //TODO: add `image` to UserService singleton (perhaps make it a map: to keep multiple images per date)
    self.uiImage = uiImage
    image = Image(uiImage: uiImage)
  }

  func updateImage(id: String) async throws {
    var data = [String: Any]()
    
    if let uiImage = uiImage {
      let imageUrl = try await ImageUploader.uploadImage(image: uiImage)
      data["imageUrl"] = imageUrl
      updatedImageURL = imageUrl
    }
    
    if !data.isEmpty {
      try await FirestoreConstants.TrainingSessionsCollection.document(id).updateData(data)
    }
  }
}
