//
//  ContentView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/10/23.
//

import SwiftUI

struct ContentView: View {
  
  @StateObject var viewModel = ContentViewModel()
  @StateObject var registrationViewModel = RegistrationViewModel()
  
  var body: some View {
    Group {
      if viewModel.userSession == nil {
        LoginView()
          .environmentObject(registrationViewModel)
      } else {
        MainTabView()
      }
    }
  }
}

#Preview {
  ContentView()
}
