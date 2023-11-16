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

    NotificationHandler.shared.handle(notification: response)
  }

  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) async -> UIBackgroundFetchResult {
    print("*** didReceiveRemoteNotification: \(userInfo)")
    return UIBackgroundFetchResult(rawValue: 8)!
  }

  // handle push nottifications recieved in the foreground
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {

    let userInfo = notification.request.content.userInfo
    let allOptions:UNNotificationPresentationOptions = [.sound, .badge, .banner, .list]
    guard let notificationType = userInfo["notificationType"] as? String else { return  allOptions }

    let fromId = userInfo["fromId"] as? String
    let date = userInfo["date"] as? String

    switch notificationType {
    case "new_direct_message":
      if let date = date?.parsedDate(), let fromId = fromId { //TODO: does this negate the need for all the below conditions?
        if date.timeIntervalSince1970 <= AppNavigation.shared.userIdDate[fromId, default: TimeInterval.infinity] {
          return [] // Don't display push notification for messages older than last read message from certain user
        }
      }

      if AppNavigation.shared.selectedTab == .Messages {
        if let screen = AppNavigation.shared.messagesNavigationStack.last {
          switch screen {
          case .chat(let user):
            if user.id == fromId {
              return [] // Don't display push notification if chat already open // messages tab
            }
          }
        }
      } else if AppNavigation.shared.selectedTab == .TrainingSessions {
        if let screen = AppNavigation.shared.trainingSessionsNavigationStack.last {
          switch screen {
          case .chat(let user):
            if user.id == fromId {
              return [] // Don't display push notification if chat already open // training sessions tab
            }
          default:
            return allOptions
          }
        }
      }
    case "new_training_session_like":
      break
    case "new_training_session_comment":
      guard let uid = userInfo["trainingSessionUid"] as? String else { return allOptions }
      if AppNavigation.shared.selectedTab == .TrainingSessions {
        if AppNavigation.shared.messagesNavigationStack.isEmpty && AppNavigation.shared.showCommentsTrainingSessionID == uid {
          return [] // Don't display push notification if corrent comments view already open
        }
      }
    default:
      break
    }

    return allOptions
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
