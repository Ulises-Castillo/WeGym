//
//  ContentView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/10/23.
//

import SwiftUI

struct ContentView: View {
  
  @StateObject var viewModel = ContentViewModel()
  
  var body: some View {
    Group {
      if viewModel.userSession == nil {
        LoginView()
      } else {
        MainTabView()
      }
    }
  }
}

#Preview {
  ContentView()
}
