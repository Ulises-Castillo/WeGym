//
//  ChatView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/26/23.
//

import SwiftUI

struct ChatView: View {
  @State private var messageText = ""
  @State private var dummyText = ""
  @State private var isInitialLoad = false
  @StateObject var viewModel: ChatViewModel
  private let user: User
  private var thread: Thread?
  //  @State var value: CGFloat = 0
  @State private var proxy: ScrollViewProxy?
  @FocusState private var inputFocused: Bool
  @State private var inputFocusedState = false
  @State private var isFirstLoad = true

  init(user: User) {
    self.user = user
    self._viewModel = StateObject(wrappedValue: ChatViewModel(user: user))
  }

  func inputPlacement() -> ToolbarItemPlacement {
    return inputFocusedState ? .keyboard : .bottomBar
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
                              nextMessage: viewModel.nextMessage(forIndex: index)) //TODO: implement pagination such that when user scrolls to the top of chat next older messages are loaded; look at MessagesView loop .onAppear()
              .id(viewModel.messages[index].id)
            }
          }
          .padding(.vertical).id("thwartKeyboard")
        }
        .toolbar {
          ToolbarItemGroup(placement: .keyboard) {
            MessageInputView(messageText: $messageText, viewModel: viewModel)
              .focused($inputFocused)
          }
          ToolbarItem(placement: .bottomBar) {
            
//            if
            HStack {
              Image(systemName: "photo")
                .padding(.horizontal, 4)
                .foregroundColor(.secondary)

              TextField("Message..", text: $dummyText, axis: .vertical)
                .frame(height: 18)
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
                .foregroundColor(.secondary)
            }
            .onTapGesture {
              DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                inputFocusedState = true
                inputFocused = true
              }
            }
          }
          //          ToolbarItem(placement: .bottomBar) {
          //            Button {
          //              inputFocused = true
          //            } label: {
          //              if (!inputFocused) {
          //                MessageInputView(messageText: $dummyText, viewModel: ChatViewModel())
          //              }
          //            }
          //          }
        }
        .scrollDismissesKeyboard(.interactively)
        .onChange(of: viewModel.messages) { newValue in
          guard  let lastMessage = newValue.last else { return }
          self.proxy = proxy

          if isFirstLoad {
            isFirstLoad = false
            proxy.scrollTo("thwartKeyboard", anchor: .bottom)
            return
          }

          withAnimation(.spring()) {
            proxy.scrollTo("thwartKeyboard", anchor: .bottom)
          }

          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { //TODO: remove hacky code
            withAnimation(.spring()) {
              proxy.scrollTo("thwartKeyboard", anchor: .bottom)
            }
          }
        }
        //        if !inputFocusedState {
        //          MessageInputView(messageText: $dummyText, viewModel: viewModel)
        //            .opacity(inputFocusedState ? 0.0 : 1.0)
        //            .onTapGesture {
        //
        //              DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
        //                withAnimation(.spring()) {
        //                  proxy.scrollTo("thwartKeyboard", anchor: .bottom)
        //                }
        //              }
        //
        //              DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        //                withAnimation(.spring()) {
        //                  proxy.scrollTo("thwartKeyboard", anchor: .bottom)
        //                }
        //              }
        //
        //              DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        //                inputFocusedState = true
        //                inputFocused = true
        //              }
        //              DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
        //                inputFocusedState = true
        //                inputFocused = true
        //              }
        //            }
        //        }
        Spacer()
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
