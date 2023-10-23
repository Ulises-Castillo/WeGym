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

class AppDelegate: NSObject, UIApplicationDelegate {
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

    Task {
      let notificationManager = NotificationManager()
      await notificationManager.getAuthStatus()
      guard !notificationManager.hasPermission else { return }
      await notificationManager.request()
    }
    return true
  }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
  // user did tap notification from outside the app
  func userNotificationCenter(_ center: UNUserNotificationCenter, 
                              didReceive response: UNNotificationResponse) async {
    if let deepLink = response.notification.request.content.userInfo["DEEP"] as? String {
      print("DEEP: BOOM !")
    }
  }

  // handle push nottifications recieved in the foreground
  func userNotificationCenter(_ center: UNUserNotificationCenter, 
                              willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
    return [.sound, .badge, .banner, .list]
  }
}

extension AppDelegate: MessagingDelegate {
  func application(_ application: UIApplication, 
                   didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
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
        .onOpenURL { url in
          print("***: \(url)")
        }
    }
  }
}
