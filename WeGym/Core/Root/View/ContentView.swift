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

  @Environment(\.scenePhase) var scenePhase

  var body: some View {
    Group {
      if viewModel.userSession == nil {
        LoginView()
          .environmentObject(registrationViewModel)
      } else if let currentUser = viewModel.currentUser {
        MainTabView(user: currentUser)
      }
    }
    .onChange(of: scenePhase) { (phase) in
      switch phase {
      case .active:
        UIApplication.shared.applicationIconBadgeNumber = 0
        Task { await NotificationService.resetBadgeCount() }
      case .background: break
      case .inactive: break
      @unknown default: break
      }
    }
  }
}

#Preview {
  ContentView()
}
