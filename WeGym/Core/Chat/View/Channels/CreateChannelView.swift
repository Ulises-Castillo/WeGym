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
        .sheet(isPresented: $imagePickerPresented, onDismiss: loadImage, content: {
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
    .navigationBarItems(trailing: createChannelButton)
  }

  func loadImage() {
    guard let selectedImage = selectedImage else { return }
    channelImage = Image(uiImage: selectedImage)
  }

  var createChannelButton: some View {
    Button(action: {
      print("Create channel")
    }, label: {
      Text("Create").bold()
        .disabled(channelName.isEmpty)
    })
  }
}

#Preview {
  CreateChannelView()
}
