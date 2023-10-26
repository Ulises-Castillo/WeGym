//
//  ChannelsView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/24/23.
//

import SwiftUI

struct ChannelsView: View {
  @State private var showCreateGroupView = false

  var body: some View {
    ZStack(alignment: .bottom) {
      ScrollView {
        VStack {
          ForEach((0...10), id: \.self) { _ in
            ChannelCell()
          }
        }
      }
      FloatingButton(show: $showCreateGroupView)
        .sheet(isPresented: $showCreateGroupView, content: {
          SelectGroupMembersView(show: $showCreateGroupView)
        })
    }
  }
}

#Preview {
  ChannelsView()
}

struct FloatingButton: View {
  @Binding var show: Bool

  var body: some View {
    Button {
      show.toggle()
    } label: {
      Image(systemName: "square.and.pencil")
        .resizable()
        .scaledToFit()
        .frame(width: 24, height:  24)
        .padding()
    }
    .background(Color(.systemBlue))
    .foregroundColor(.white)
    .clipShape(Circle())
    .padding()
  }
}
