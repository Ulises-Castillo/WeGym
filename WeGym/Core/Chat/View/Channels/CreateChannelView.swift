//
//  CreateChannelView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/26/23.
//

import SwiftUI

struct CreateChannelView: View {
  @State private var channelName = ""
  @State private var imagePickerPresented = false
  @State private var selectedImage: UIImage?
  @State private var channelImage: Image?
  @ObservedObject var viewModel: CreateChannelViewModel
  @Binding var show: Bool

  init(_ selectableUsers: [SelectableUser], show: Binding<Bool>) {
    self.viewModel = CreateChannelViewModel(selectableUsers)
    self._show = show
  }

  var body: some View {
    VStack(alignment: .leading) {
      HStack(spacing: 32) {
        Button(action: {
          imagePickerPresented.toggle()
        }, label: {
          let image = channelImage == nil ? Image(systemName: "plus") : channelImage!
            image
              .resizable()
              .scaledToFill()
              .frame(width: 64, height: 64)
              .clipShape(Circle())
        })
        .sheet(isPresented: $imagePickerPresented, onDismiss: loadImage, content: { //TODO: use same image picker from edit profile
//          ImagePicker(image: $selectedImage)
        })
        .padding(.leading)

        VStack(alignment: .leading, spacing: 12) {
          Rectangle()
            .frame(height: 0.5)
            .foregroundColor(Color(.separator))

          TextField("Enter a name for your channel", text: $channelName)
            .font(.system(size: 15))

          Rectangle()
            .frame(height: 0.5)
            .foregroundColor(Color(.separator))

          Text("Please provide a channel name and icon")
            .font(.system(size: 14))
            .foregroundStyle(.gray)
        }.padding()
      }
      Spacer()
    }
    .onReceive(viewModel.$didCreateChannel, perform: { completed in
      if completed {
        show.toggle()
      }
    })
    .navigationBarItems(trailing: createChannelButton)
  }

  func loadImage() {
    guard let selectedImage = selectedImage else { return }
    channelImage = Image(uiImage: selectedImage)
  }

  var createChannelButton: some View {
    Button(action: {
      Task { try await viewModel.createChannel(name: channelName, image: selectedImage) }
    }, label: {
      Text("Create").bold()
        .disabled(channelName.isEmpty)
    })
  }
}