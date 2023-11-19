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
  @State var image = Image(systemName: "person.circle.fill")

  var body: some View {
    if let profileImage = UserService.shared.profileImage, let user = user, user.isCurrentUser {
      Image(uiImage: profileImage)
        .resizable()
        .scaledToFill()
        .frame(width: size.dimension, height: size.dimension)
        .clipShape(Circle())
        .onTapGesture {
          AppNavigation.shared.image = Image(uiImage: profileImage)
          AppNavigation.shared.showImageViewer.toggle()
        }
    } else if let imageUrl = user?.profileImageUrl {
      KFImage(URL(string: imageUrl))
        .placeholder {
          Image(systemName: "person.circle.fill")
            .resizable()
            .frame(width: size.dimension, height: size.dimension)
            .clipShape(Circle())
            .foregroundColor(Color(.systemGray4))
            .opacity(0.3)
        }
        .onSuccess { result in
          image = Image(uiImage: result.image)
        }
        .resizable()
        .scaledToFill()
        .frame(width: size.dimension, height: size.dimension)
        .clipShape(Circle())
        .onTapGesture {
          AppNavigation.shared.image = image
          AppNavigation.shared.showImageViewer.toggle()
        }
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
