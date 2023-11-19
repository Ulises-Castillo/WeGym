//
//  CommentCell.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/23/23.
//

import SwiftUI

struct CommentCell: View {

  let comment: Comment
  @StateObject var userService = UserService.shared

  private var user: User? {
    return comment.user
  }

  var body: some View {
    HStack {
      CircularProfileImageView(user: user, size: .xSmall)
        .disabled(true)

      VStack(alignment: .leading, spacing: 4) {
        HStack(spacing: 2) {
          Text(user?.fullName ?? user?.username ?? "" + " ")
            .fontWeight(.semibold)
            .foregroundColor(.primary)

          Text(comment.timestamp.timestampString())
            .foregroundColor(.secondary)
        }
        Text(attributedString(from: comment.commentText))
          .foregroundColor(.primary)
          .textSelection(.enabled)
      }
      .font(.caption)
      Spacer()
    }
    .padding(.horizontal)
  }
}

struct CommentCell_Previews: PreviewProvider {
  static var previews: some View {
    CommentCell(comment: dev.comment)
  }
}


