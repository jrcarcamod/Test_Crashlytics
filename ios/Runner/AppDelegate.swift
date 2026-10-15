import Flutter
import UIKit
import DigitalReefSDK

@main
@objc class AppDelegate: FlutterAppDelegate {
    private let digitalReef = DigitalReef.shared
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      UNUserNotificationCenter.current().delegate = self
      GeneratedPluginRegistrant.register(with: self)
      application.registerForRemoteNotifications()
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
            let isDigitalReefNotification =
                        DigitalReef.shared.canHandleNotification(userInfo: userInfo)

            if isDigitalReefNotification {
                print("DR SDK")

                DigitalReef.shared.didReceiveRemoteNotification(
                    application: application,
                    userInfo: userInfo,
                    fetchCompletionHandler: completionHandler
                )
            } else {
                print("OTHER SDK")

            }
        }
        
        override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
            DigitalReef.shared.didRegisterForRemoteNotificationsWithDeviceToken(application, deviceToken: deviceToken)
        }
        
        override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
            let userInfo = response.notification.request.content.userInfo
            let isDigitalReefNotification =
                DigitalReef.shared.canHandleNotification(userInfo: userInfo)

            if isDigitalReefNotification {
                DigitalReef.shared.didReceiveNotificationResponse(
                    center: center,
                    didReceive: response,
                    withCompletionHandler: completionHandler
                )
            } else {
                print("OTHER SDK")
            }
        }
    
    override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            let userInfo = notification.request.content.userInfo
            let isDigitalReefNotification =
                DigitalReef.shared.canHandleNotification(userInfo: userInfo)

            if isDigitalReefNotification {
                print("DR SDK")

                DigitalReef.shared.willPresentNotification(
                    center: center,
                    willPresent: notification,
                    withCompletionHandler: completionHandler
                )
            } else {
                print("OTHER SDK")

            }
        }
}
