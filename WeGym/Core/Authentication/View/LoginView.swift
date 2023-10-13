//
//  LoginView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/12/23.
//

import SwiftUI

struct LoginView: View {
  
  @State private var email = ""
  @State private var password = ""
  
  var body: some View {
    NavigationStack {
      VStack {
        Spacer()
        
        // logo image
        Text("WeGym") //TODO: ask Jeff for logo image
          .font(.system(size: 66))
        
        // text fields
        VStack {
          TextField("Enter your email", text: $email)
            .autocapitalization(.none)
            .modifier(WGTextFieldModifier())
          
          SecureField("Enter your password", text: $password)
            .modifier(WGTextFieldModifier())
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
          print("Log In")
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
  }
}

#Preview {
  LoginView()
}
