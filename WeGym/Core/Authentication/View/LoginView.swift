//
//  LoginView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/12/23.
//

import SwiftUI

struct LoginView: View {

  @StateObject var viewModel = LoginViewModel()
  @AppStorage("USER_EMAIL") var savedEmail = ""
  @FocusState var isPasswordInputFocused: Bool

  var body: some View {
    NavigationStack {
      VStack {
        Spacer()

        // logo image
        Text("WeGym") //TODO: ask Jeff for logo image
          .font(.system(size: 66))

        // text fields
        VStack {
          TextField("Enter your email", text: $viewModel.email)
            .autocapitalization(.none)
            .modifier(WGTextFieldModifier())
            .clearButton(text: $viewModel.email)
            .onChange(of: viewModel.email) { email in
              self.savedEmail = email
            }
            .onAppear {
              viewModel.email = savedEmail
            }

          SecureField("Enter your password", text: $viewModel.password)
            .focused($isPasswordInputFocused)
            .modifier(WGTextFieldModifier())
            .clearButton(text: $viewModel.password)
        }

        Button {
          print("Show forgot password")
        } label: {
          Text("Forgot Password?")
            .font(.footnote)
            .fontWeight(.semibold)
            .padding(.top)
            .padding(.trailing, 28)

        }
        .frame(maxWidth: .infinity, alignment: .trailing)

        Button {
          Task { 
            try await viewModel.signIn()
            TrainingSessionService.clearFetchedDates()
          }
        } label: {
          Text("Log In")
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(width: 360, height: 44)
            .background(Color(.systemBlue))
            .cornerRadius(8)
        }
        .padding(.vertical)

        Spacer()

        Divider()

        NavigationLink {
          AddEmailView()
            .navigationBarBackButtonHidden()
        } label: {
          HStack(spacing: 3) {
            Text("New around here?")
            Text("Sign Up")
              .fontWeight(.semibold)
          }
          .font(.footnote)
        }
        .padding(.vertical, 16)
      }
    }
    .onAppear {
      if savedEmail.contains("@") && savedEmail.contains(".") {
        isPasswordInputFocused = true
      }
    }
  }
}

struct ClearButton: ViewModifier { //TODO: move to extensions
  @Binding var text: String

  func body(content: Content) -> some View {
    ZStack(alignment: .trailing) {
      content

      if !text.isEmpty {
        Button {
          text = ""
        } label: {
          Image(systemName: "multiply.circle.fill")
            .resizable()
            .frame(width: 18, height: 18)
            .foregroundStyle(.gray)
        }
        .padding(.trailing, UIScreen.main.bounds.width / 11)
      }
    }
  }
}

extension View {
  func clearButton(text: Binding<String>) -> some View {
    modifier(ClearButton(text: text))
  }
}

#Preview {
  LoginView()
}
