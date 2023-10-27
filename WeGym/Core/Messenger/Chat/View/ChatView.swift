//
//  ChatView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/26/23.
//

import SwiftUI

struct ChatView: View {
  @State private var messageText = ""
  @State private var isInitialLoad = false
  @StateObject var viewModel: ChatViewModel
  private let user: User
  private var thread: Thread?
//  @State var value: CGFloat = 0
  @State private var proxy: ScrollViewProxy?
  @FocusState private var inputFocused: Bool

  init(user: User) {
    self.user = user
    self._viewModel = StateObject(wrappedValue: ChatViewModel(user: user))
  }
  
  var body: some View {
    VStack {
      ScrollViewReader { proxy in
        ScrollView {
          LazyVStack {
            VStack {
              CircularProfileImageView(user: user, size: .xLarge)
              
              VStack(spacing: 4) {
                Text(user.fullName ?? user.username)
                  .font(.title3)
                  .fontWeight(.semibold)
                
                if user.fullName != nil {
                  Text(user.username)
                    .font(.footnote)
                    .foregroundColor(.gray)
                }
              }
            }
            
            ForEach(viewModel.messages.indices, id: \.self) { index in
              ChatMessageCell(message: viewModel.messages[index],
                              nextMessage: viewModel.nextMessage(forIndex: index))
              .id(viewModel.messages[index].id)
            }
          }
          .padding(.vertical)
          Spacer().id("thwartKeyboard")
        }
        .scrollDismissesKeyboard(.interactively)
        .onChange(of: viewModel.messages) { newValue in
          guard  let lastMessage = newValue.last else { return }
          self.proxy = proxy

          withAnimation(.spring()) {
            proxy.scrollTo("thwartKeyboard")
          }

          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring()) {
              proxy.scrollTo("thwartKeyboard")
            }
          }
        }
        MessageInputView(messageText: $messageText, viewModel: viewModel)
          .focused($inputFocused)
          .onTapGesture {
            inputFocused = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
              withAnimation(.spring()) {
                proxy.scrollTo("thwartKeyboard")
              }
            }
          }
      }

    }
//    .onAppear {
//      NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
//        let value = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
//        let height = value.height
//
////        self.value = height
//        viewModel.messages = viewModel.messages
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
//          self.proxy?.scrollTo("thwartKeyboard")
//        }
//      }
//
//      NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { notification in
////        let value = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
////        let height = value.height
//
////        self.value = 0
//      }
//    }
    .onDisappear {
      viewModel.removeChatListener()
    }
    .onChange(of: viewModel.messages, perform: { _ in
      Task { try await viewModel.updateMessageStatusIfNecessary()}
    })
    .navigationTitle(user.fullName ?? user.username)
    .navigationBarTitleDisplayMode(.inline)
  }
}

//struct ChatView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatView(user: dev.user)
//    }
//}
