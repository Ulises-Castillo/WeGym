//
//  CreateUsernameView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/12/23.
//

import SwiftUI

//TODO: refactor – duplicate of "Add Email View"
struct CreateUsernameView: View {

  @Environment(\.dismiss) var dismiss
  @EnvironmentObject var viewModel: RegistrationViewModel
  @FocusState var inputFocused: Bool
  @State private var showCreatePasswordView = false
  @State private var usernameTemp = ""

  var body: some View {
    VStack(spacing: 12) {
      Text("Create username")
        .font(.title2)
        .fontWeight(.bold)
        .padding(.top)

      Text("Username must be at least 4 characters.")
        .font(.footnote)
        .foregroundColor(.gray)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 24)
        .padding(.top, 1)

      ZStack(alignment: .trailing) {
        TextField("Username", text: $viewModel.username)
          .keyboardType(.alphabet)
          .textContentType(.oneTimeCode)
          .autocapitalization(.none)
          .modifier(WGTextFieldModifier())
          .padding(.top)
          .autocorrectionDisabled()
          .focused($inputFocused)

        if viewModel.isLoading {
          ProgressView()
            .padding(.trailing, 40)
            .padding(.top, 14)
        }

        if viewModel.usernameValidationFailed {
          Image(systemName: "xmark.circle.fill")
            .imageScale(.large)
            .fontWeight(.bold)
            .foregroundColor(Color(.systemRed))
            .padding(.trailing, 40)
            .padding(.top, 14)
        }
      }

      if viewModel.usernameValidationFailed {

        Text("\(usernameTemp) is taken.")
          .font(.caption)
          .foregroundColor(Color(.systemRed))
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.horizontal, 28)
      }

      Button {
        Task {
          usernameTemp = viewModel.username
          try await viewModel.validateUsername()
        }
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
    .onReceive(viewModel.$usernameIsValid, perform: { usernameIsValid in
      if usernameIsValid {
        self.showCreatePasswordView.toggle()
      }
    })
    .navigationDestination(isPresented: $showCreatePasswordView, destination: {
      CreatePasswordView()
        .navigationBarBackButtonHidden()
    })
    .onAppear {
      showCreatePasswordView = false
      viewModel.usernameIsValid = false
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

extension CreateUsernameView {
  var formIsValid: Bool {
    return viewModel.username.count > 3
  }
}

#Preview {
  CreateUsernameView()
}
