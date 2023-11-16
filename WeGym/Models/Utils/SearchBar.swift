//
//  SearchBar.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/24/23.
//

import SwiftUI

struct SearchBar: View {
  @Binding var text: String
  @Binding var isEditing: Bool

  var body: some View {
    HStack {
      TextField("Search...", text: $text)
        .padding(8)
        .padding(.horizontal, 28)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .overlay {
          Image(systemName: "magnifyingglass")
            .foregroundColor(.gray)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 8)
        }

      if isEditing {
        Button {
          isEditing = false
          text = ""
          UIApplication.shared.endEditing()
        } label: {
          Text("Cancel")
            .foregroundStyle(.black)
        }
        .padding(.trailing, 8)
        .transition(.move(edge: .trailing))
        .animation(.default) //TODO: update with new API
      }
    }
  }
}

#Preview {
  SearchBar(text: .constant("Search..."), isEditing: .constant(false))
}
