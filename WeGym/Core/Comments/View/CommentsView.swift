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
  @FocusState var inputFocused
  @State var viewMode = false

  private var currentUser: User? {
    return UserService.shared.currentUser
  }

  init(trainingSession: TrainingSession, viewMode: Bool = false) {
    self.viewMode = viewMode
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

      ScrollViewReader { proxy in
        ScrollView {
          Spacer(minLength: 0).id("comments_top")
          LazyVStack(spacing: 24) {
            ForEach(viewModel.comments) { comment in
              CommentCell(comment: comment)
            }
          }
        }
        .onTapGesture {
          inputFocused = false
        }
        .padding(.top)

        Divider()
        
        HStack(spacing: 12) {
          CircularProfileImageView(user: currentUser, size: .xSmall)

          ZStack(alignment: .trailing) {
            TextField("Add a comment", text: $commentText, axis: .vertical)
              .focused($inputFocused)
              .font(.footnote)
              .padding(12)
              .padding(.trailing, 40)
              .multilineTextAlignment(.leading)
              .foregroundColor(.primary)
              .overlay {
                Capsule()
                  .stroke(Color(.systemGray5), lineWidth: 1)
              }
            if !commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
              Button {
                Task {
                  let commentTextCopy = commentText
                  commentText = ""
                  if !commentTextCopy.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    try await viewModel.uploadComment(commentText: commentTextCopy)
                  }
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

        }
        .padding()
        .onChange(of: viewModel.comments) { newValue in
          withAnimation(.spring()) {
            proxy.scrollTo("comments_top", anchor: .top)
          }
        }
      }
    }
    .onAppear {
      inputFocused = !viewMode
    }
    .onDisappear {
      viewModel.removeChatListener()
    }
  }
}

//#Preview {
//  CommentsView()
//}
