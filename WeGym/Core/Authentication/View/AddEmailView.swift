//
//  AddEmailView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/12/23.
//

import SwiftUI

struct AddEmailView: View {
  @Environment(\.dismiss) var dismiss
  @EnvironmentObject var viewModel: RegistrationViewModel
  @FocusState var inputFocused: Bool

  var body: some View {
    VStack(spacing: 12) {
      Text("Add your email")
        .font(.title2)
        .fontWeight(.bold)
        .padding(.top)
      
      Text("You'll use this email to sign to your account")
        .font(.footnote)
        .foregroundColor(.gray)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 24)
        .padding(.top, 1)
      
      TextField("Email", text: $viewModel.email)
        .keyboardType(.asciiCapable)
        .textContentType(.oneTimeCode)
        .disableAutocorrection(true)
        .autocapitalization(.none)
        .autocorrectionDisabled(true)
        .modifier(WGTextFieldModifier())
        .padding(.top)
        .focused($inputFocused)

      NavigationLink {
        CreateUsernameView()
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

#Preview {
  AddEmailView()
}
