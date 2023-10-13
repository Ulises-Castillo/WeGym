//
//  CreatePasswordView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/12/23.
//

import SwiftUI

struct CreatePasswordView: View {
  @State private var password = ""
  @Environment(\.dismiss) var dismiss
  
  var body: some View {
    VStack(spacing: 12) {
      Text("Create a password")
        .font(.title2)
        .fontWeight(.bold)
        .padding(.top)
      
      Text("Your password must be at least 6 characters in length")
        .font(.footnote)
        .foregroundColor(.gray)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 24)
        .padding(.top, 1)
      
      SecureField("Password", text: $password)
        .autocapitalization(.none)
        .modifier(WGTextFieldModifier())
        .padding(.top)
      
      NavigationLink {
        CompleteSignUpView()
          .navigationBarBackButtonHidden()
      } label: {
        Text("Next")
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
  CreatePasswordView()
}
