//
//  CommentsView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/23/23.
//

import SwiftUI

struct CommentsView: View {
  @State private var commentText = ""
  @StateObject var viewModel: CommentsViewModel

  private var currentUser: User? {
    return UserService.shared.currentUser
  }

  init(trainingSession: TrainingSession) {
    self._viewModel = StateObject(wrappedValue: CommentsViewModel(trainingSession: trainingSession))
  }

  var body: some View {
    VStack {
      Text("Comments")
        .font(.subheadline)
        .fontWeight(.semibold)
        .padding(.top, 24)
        .foregroundColor(.primary)

      Divider()

      ScrollView {
        LazyVStack(spacing: 24) {
          ForEach(viewModel.comments) { comment in
            CommentCell(comment: comment)
          }
        }
      }
      .padding(.top)

      Divider()

      HStack(spacing: 12) {
        CircularProfileImageView(user: currentUser, size: .xSmall)

        ZStack(alignment: .trailing) {
          TextField("Add a comment", text: $commentText, axis: .vertical)
            .font(.footnote)
            .padding(12)
            .padding(.trailing, 40)
            .multilineTextAlignment(.leading)
            .foregroundColor(.primary)
            .overlay {
              Capsule()
                .stroke(Color(.systemGray5), lineWidth: 1)
            }
          Button {
            Task {
              let commentTextCopy = commentText
              commentText = ""
              try await viewModel.uploadComment(commentText: commentTextCopy)

            }
          } label: {
            Text("Post")
              .font(.subheadline)
              .fontWeight(.semibold)
              .foregroundColor(Color(.systemBlue))
          }
          .padding(.horizontal)
        }

      }
      .padding()
    }
  }
}

//#Preview {
//  CommentsView()
//}
