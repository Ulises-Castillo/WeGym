//
//  CompleteSignUpView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/12/23.
//

import SwiftUI

struct CompleteSignUpView: View {
  @Environment(\.dismiss) var dismiss
  
  var body: some View {
    VStack(spacing: 12) {
      Spacer()
      Text("Welcome to WeGym,\nmaster_ulysses")
        .font(.title2)
        .fontWeight(.bold)
        .multilineTextAlignment(.center)
        .padding(.top)
      
      Text("Tap to complete sign up and start using WeGym")
        .font(.footnote)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 24)
        .padding(.top, 1)
      
      Button {
        print("Complete sign up")
      } label: {
        Text("Complete Sign Up")
          .font(.subheadline)
          .fontWeight(.semibold)
          .foregroundColor(.white)
          .frame(width: 360, height: 44)
          .background(Color(.systemBlue))
          .cornerRadius(8)
      }
      .padding(.vertical)
      
      Spacer()
    }
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        Image(systemName: "chevron.left")
          .imageScale(.large)
          .onTapGesture {
            dismiss()
          }
        
      }
    }
  }
}

#Preview {
  CompleteSignUpView()
}
