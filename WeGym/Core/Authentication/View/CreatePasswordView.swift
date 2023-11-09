//
//  CreatePasswordView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/12/23.
//

import SwiftUI

struct CreatePasswordView: View {
  
  @Environment(\.dismiss) var dismiss
  @EnvironmentObject var viewModel: RegistrationViewModel
  @FocusState var inputFocused: Bool

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

      SecureField("Password", text: $viewModel.password)
        .autocapitalization(.none)
        .modifier(WGTextFieldModifier())
        .padding(.top)
        .focused($inputFocused)

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
      .disabled(!formIsValid)
      .opacity(formIsValid ? 1.0 : 0.5)
      .padding(.vertical)
      
      Spacer()
    }
    .onAppear {
      inputFocused = true
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

extension CreatePasswordView {
    var formIsValid: Bool {
      return viewModel.password.count > 5
    }
}

#Preview {
  CreatePasswordView()
}
