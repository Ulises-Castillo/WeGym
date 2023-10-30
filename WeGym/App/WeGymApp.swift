//
//  WeGymApp.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/10/23.
//

import SwiftUI
import Firebase
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

    print("*** user tapped notification from outside the app: \(response.notification.request.content.userInfo)")
    NotificationHandler.shared.handle(notification: response)
    

//    if let deepLink = response.notification.request.content.userInfo["DEEP"] as? String {
//      print("*** DEEP: BOOM !")
//    }
  }

  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) async -> UIBackgroundFetchResult {
    print("*** didReceiveRemoteNotification: \(userInfo)")
    return UIBackgroundFetchResult(rawValue: 8)!
  }

  // handle push nottifications recieved in the foreground
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {

    if (notification.request.content.userInfo["notificationType"] as? String) == "new_direct_message" {
      let fromId = notification.request.content.userInfo["fromId"] as? String
      if AppNavigation.shared.selectedTab == .Messages {
        if let screen = AppNavigation.shared.messagesNavigationStack.last {
          switch screen {
          case .chat(let user):
            if user.id == fromId {
              return []
            }
          }
        }
      }
    } else {
      
    }

    return [.sound, .badge, .banner, .list]
  }
}

extension AppDelegate: MessagingDelegate {
  func application(_ application: UIApplication,
                   didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
  }

  //TODO: implement stale token pruning
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    guard let token = Messaging.messaging().fcmToken,
          let uid = Auth.auth().currentUser?.uid else { return }

    let deviceToken: [String: Any] = [
      "token": token,
      "timestamp": Timestamp()
    ]

    Firestore.firestore().collection("fcmTokens").document(uid).setData(deviceToken)
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
