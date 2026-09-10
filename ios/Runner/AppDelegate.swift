import UIKit
import Flutter
import GoogleMaps
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // Google Maps API Key
    GMSServices.provideAPIKey("AIzaSyA-pUy2TNFHhUoHzdXP49xylTJgrcGXTYg")

    // Register Flutter plugins (includes FirebaseMessaging plugin which sets
    // up APNs swizzling and UNUserNotificationCenter delegate automatically).
    GeneratedPluginRegistrant.register(with: self)

    // Set this app as the UNUserNotificationCenter delegate so the system
    // calls willPresent(_:withCompletionHandler:) when a notification
    // arrives while the app is in the foreground.
    //
    // The FlutterAppDelegate superclass already conforms to
    // UNUserNotificationCenterDelegate, so we just set the delegate here.
    // firebase_messaging will call the completion handler with the correct
    // presentation options based on setForegroundNotificationPresentationOptions.
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }

    return super.application(
      application,
      didFinishLaunchingWithOptions: launchOptions
    )
  }
}
