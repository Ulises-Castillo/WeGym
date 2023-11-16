//
//  UserStatView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/12/23.
//

import SwiftUI

struct UserStatView: View {
  let value: String
  let title: String
  
  var body: some View {
    VStack {
      Text(value)
        .font(.subheadline)
        .fontWeight(.semibold)
      Text(title)
        .font(.footnote)
    }
    .frame(width: 76)
  }
}

#Preview {
  UserStatView(value: "245", title: "Bench")
}
