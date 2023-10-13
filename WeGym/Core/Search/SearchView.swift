//
//  SearchView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/12/23.
//

import SwiftUI

struct SearchView: View {
  @State private var searchText = ""
  
  var body: some View {
    NavigationStack {
      ScrollView {
        LazyVStack(spacing: 12) {
          ForEach(0 ... 33, id: \.self) { user in
            HStack {
              Image("uly")
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
              
              VStack(alignment: .leading) {
                Text("master_ulysses")
                  .fontWeight(.semibold)
                
                Text("Ulysses A. Castillo")
              }
              .font(.footnote)
              
              Spacer()
            }
            .padding(.horizontal)
          }
        }
        .padding(.top, 8)
        .searchable(text: $searchText, prompt: "Search..")
      }
      .navigationTitle("Add Gym Bros")
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}

#Preview {
  SearchView()
}
