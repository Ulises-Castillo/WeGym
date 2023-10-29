//
//  CircularProfileImageView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/13/23.
//

import SwiftUI
import Kingfisher

enum ProfileImageSize {
  case xxSmall
  case xxSmall32
  case xSmall
  case small
  case medium
  case large
  case xLarge
  
  var dimension: CGFloat {
    switch self {
    case .xxSmall:
      return 28
    case .xxSmall32:
      return 32
    case .xSmall:
      return 40
    case .small:
      return 48
    case .medium:
      return 64
    case .large:
      return 80
    case .xLarge:
      return 88
    }
  }
}

struct CircularProfileImageView: View {
  var user: User?
  let size: ProfileImageSize
  
  var body: some View {
    if let profileImage = UserService.shared.profileImage, let user = user, user.isCurrentUser {
      Image(uiImage: profileImage)
        .resizable()
        .scaledToFill()
        .frame(width: size.dimension, height: size.dimension)
        .clipShape(Circle())
    } else if let imageUrl = user?.profileImageUrl {
      KFImage(URL(string: imageUrl))
        .resizable()
        .scaledToFill()
        .frame(width: size.dimension, height: size.dimension)
        .clipShape(Circle())
    } else {
      Image(systemName: "person.circle.fill")
        .resizable()
        .frame(width: size.dimension, height: size.dimension)
        .clipShape(Circle())
        .foregroundColor(Color(.systemGray4))
    }
  }
}

#Preview {
  CircularProfileImageView(user: User.MOCK_USERS[0], size: .large)
}
