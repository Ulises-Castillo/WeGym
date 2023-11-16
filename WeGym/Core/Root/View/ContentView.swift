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
      if viewModel.userSession == nil && viewModel.currentUser == nil {
        LoginView()
          .environmentObject(registrationViewModel)
      } else if let currentUser = viewModel.currentUser {
        MainTabView(user: currentUser)
      } else {
        VStack {
          ProgressView()
            .scaleEffect(1, anchor: .center)
            .progressViewStyle(CircularProgressViewStyle(tint: Color(.systemBlue)))
            .padding(.top, UIScreen.main.bounds.height/7.4)
            .frame(width: 50)
            .onAppear { //FIX: prevent infinite loading spinner caused by user being deleted in the backend, but still logged in locally
              Timer.scheduledTimer(withTimeInterval: 9.0, repeats: false) { _ in
                guard viewModel.currentUser == nil else { return }
                AuthService.shared.signOut()
              }
            }
          Spacer()
        }
      }
    }
    .onChange(of: scenePhase) { (phase) in
      switch phase {
      case .background:
        UIApplication.shared.applicationIconBadgeNumber = 0
        Task { await NotificationService.resetBadgeCount() }
      case .active, .inactive: break
      @unknown default: break
      }
    }
  }
}

#Preview {
  ContentView()
}
