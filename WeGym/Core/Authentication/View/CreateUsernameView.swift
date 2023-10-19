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
      
      TextField("Username", text: $viewModel.username)
        .autocapitalization(.none)
        .modifier(WGTextFieldModifier())
        .padding(.top)
        .autocorrectionDisabled()
      
      NavigationLink {
        CreatePasswordView()
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
  CreateUsernameView()
}
