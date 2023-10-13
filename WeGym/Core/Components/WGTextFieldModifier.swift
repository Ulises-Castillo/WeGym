//
//  WGTextFieldModifier.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/12/23.
//

import SwiftUI

struct WGTextFieldModifier: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(.subheadline)
      .padding(12)
      .background(Color(.systemGray6))
      .cornerRadius(10)
      .padding(.horizontal, 24)
  }
}
