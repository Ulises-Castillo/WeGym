//
//  MessageInputView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/26/23.
//

import SwiftUI

import SwiftUI
import PhotosUI

struct MessageInputView: View {
  @Binding var messageText: String
  @ObservedObject var viewModel: ChatViewModel

  var body: some View {
    ZStack(alignment: .trailing) {
      HStack {
        if let image = viewModel.messageImage {
          ZStack(alignment: .topTrailing) {
            image
              .resizable()
              .scaledToFill()
              .clipped()
              .frame(width: 80, height: 140)
              .cornerRadius(10)

            Button(action: {
              viewModel.messageImage = nil
            }, label: {
              Image(systemName: "xmark")
                .resizable()
                .scaledToFit()
                .frame(width: 10, height: 10)
                .padding(8)
            })
            .background(Color(.gray))
            .foregroundColor(.white)
            .clipShape(Circle())
          }
          .padding(8)

          Spacer()
        } else {
          if messageText.isEmpty {
            PhotosPicker(selection: $viewModel.selectedItem) {
              Image(systemName: "photo")
                .padding(.horizontal, 4)
                .foregroundColor(.gray)
            }
          }

          TextField("Message..", text: $messageText, axis: .vertical)
            .padding(12)
            .padding(.leading, 4)
            .padding(.trailing, 48)
          //            .background(Color.theme.secondaryBackground)
          //            .clipShape(Capsule())
            .font(.subheadline)
            .background(
              Capsule()
                .strokeBorder(Color.gray,lineWidth: 0.8)
                .background(Color.theme.secondaryBackground)
                .clipped()
            )
            .clipShape(Capsule())
        }
      }

      if !messageText.isEmpty || viewModel.messageImage != nil {
        Button {
          let msgCopy = messageText
          messageText = ""
          Task {
            try await viewModel.sendMessage(msgCopy)
          }
        } label: {
          Image(systemName: "arrow.up.circle.fill")
            .resizable()
            .frame(width: 27, height: 27)
        }
        .padding(.horizontal)
      }

    }
    .overlay {
      if viewModel.messageImage != nil {
        RoundedRectangle(cornerRadius: 10)
          .stroke(Color(.systemGray4), lineWidth: 1)
      }
    }
    .padding(.horizontal)
    .padding(.bottom, 8)
  }
}

//struct MessageInputView_Previews: PreviewProvider {
//    static var previews: some View {
//        MessageInputView(messageText: .constant(""),
//                         viewModel: ChatViewModel(user: dev.user))
//    }
//}
