//
//  ImageUploader.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/13/23.
//

import UIKit
import Firebase
import FirebaseStorage

struct ImageUploader {
  static func uploadImage(image: UIImage) async throws -> String? {
    guard let imageData = image.jpegData(compressionQuality: 0.33) else { return nil }
    let fileName = NSUUID().uuidString
    let ref = Storage.storage().reference(withPath: "/profile_image/\(fileName)")
    
    do {
      let _ = try await ref.putDataAsync(imageData)
      let url = try await ref.downloadURL()
      return url.absoluteString
    } catch {
      print("DEBUG: Failed to upload image with error \(error.localizedDescription)")
      return nil
    }
  }
}
