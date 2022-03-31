//
//  AppDelegate.swift
//  VerifyVerloop
//
//  Created by Sreedeep on 28/01/22.
//

import UIKit


@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    var deviceToken : String!

    func registerForPushNotifications() {
        
        UNUserNotificationCenter.current()
          .requestAuthorization(
            options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            print("Permission granted: \(granted)")
            guard granted else { return }
            self?.getNotificationSettings()
          }
        
    }
    func getNotificationSettings() {
      
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        print("Notification settings: \(settings)")
          guard settings.authorizationStatus == .authorized else { return }
          DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
          }
      }
    }
    func application(
      _ application: UIApplication,
      didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
      let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
      let token = tokenParts.joined()
      print("Device Token: \(token)")
        self.deviceToken = token
//        UserDefaults.standard.set(token, forKey: "Device_token")
        UserDefaults.standard.set(self.deviceToken, forKey: "Device_token")
//        UserDefaults.standard.setvalue(self.deviceToken, key:"Device_token")
    }
    func application(
      _ application: UIApplication,
      didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
      print("Failed to register: \(error)")
    }
    // MARK: UISceneSession Lifecycle
    func application(
      _ application: UIApplication,
      didReceiveRemoteNotification userInfo: [AnyHashable: Any],
      fetchCompletionHandler completionHandler:
      @escaping (UIBackgroundFetchResult) -> Void
    ) {
      guard let aps = userInfo["aps"] as? [String: AnyObject] else {
        completionHandler(.failed)
        return
      }

    }
    public static var isAvailable: Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        if #available(iOSApplicationExtension 10.0, iOS 10.0, *) {
            guard let regionCode = Locale.current.regionCode
            else {
                return false
            }
            return regionCode.lowercased() != "cn" || regionCode.lowercased() != "chn"
        } else {
            return false
        }
        #endif
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let regionCode = Locale.current.regionCode
        // Override point for customization after application launch.
//        UIApplication.shared.registerForRemoteNotifications()
        
//        registerForPushNotifications()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}
//extension ReferenceModels {
//    var deviceToken : String {
//   let appDelegate = UIApplication.shared.delegate as! AppDelegate
//// Device
//        return appDelegate.deviceToken
//// Simulator
////        return "deviceToken"
//    }
//}
