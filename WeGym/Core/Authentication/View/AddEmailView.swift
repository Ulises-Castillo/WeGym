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
  @State private var showCreateUsernameView = false
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

      ZStack(alignment: .trailing) {
        TextField("Email", text: $viewModel.email)
          .keyboardType(.asciiCapable)
          .textContentType(.oneTimeCode)
          .disableAutocorrection(true)
          .autocapitalization(.none)
          .autocorrectionDisabled(true)
          .modifier(WGTextFieldModifier())
          .padding(.top)
          .focused($inputFocused)

        if viewModel.isLoading {
          ProgressView()
            .padding(.trailing, 40)
            .padding(.top, 14)
        }

        if viewModel.emailValidationFailed {
          Image(systemName: "xmark.circle.fill")
            .imageScale(.large)
            .fontWeight(.bold)
            .foregroundColor(Color(.systemRed))
            .padding(.trailing, 40)
            .padding(.top, 14)
        }
      }

      if viewModel.emailValidationFailed {
        Text("This email is already in use.")
          .font(.caption)
          .foregroundColor(Color(.systemRed))
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.horizontal, 28)
      }


      Button {
        Task { try await viewModel.validateEmail() }
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
    .onReceive(viewModel.$emailIsValid, perform: { emailIsValid in
      if emailIsValid {
        self.showCreateUsernameView.toggle()
      }
    })
    .navigationDestination(isPresented: $showCreateUsernameView, destination: {
      CreateUsernameView()
        .navigationBarBackButtonHidden()
    })
    .onAppear {
      showCreateUsernameView = false
      viewModel.emailIsValid = false
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

extension AddEmailView {
  var formIsValid: Bool {
    return !viewModel.email.isEmpty
    && viewModel.email.contains("@")
    && viewModel.email.contains(".")
  }
}

#Preview {
  AddEmailView()
}
