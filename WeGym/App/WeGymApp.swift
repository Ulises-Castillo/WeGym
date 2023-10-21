//
//  WeGymApp.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/10/23.
//

import SwiftUI
import FirebaseCore
import FirebaseMessaging

#if DEBUG
import FirebaseAppCheck
#endif


class AppDelegate: NSObject, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

#if DEBUG
    let providerFactory = AppCheckDebugProviderFactory()
    AppCheck.setAppCheckProviderFactory(providerFactory)
#endif

    application.registerForRemoteNotifications()
    FirebaseApp.configure()
    Messaging.messaging().delegate = self
    UNUserNotificationCenter.current().delegate = self


    return true
  }

  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
  }

  //TODO: is this needed? or only for push notification testing
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    if let fcm = Messaging.messaging().fcmToken {
      print("\n\nfcm**", fcm)
    }
  }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

@main
struct WeGymApp: App {
  // register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}
