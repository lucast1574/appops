import Flutter
import UIKit
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Initialise Firebase before anything else.
    FirebaseApp.configure()

    // APNs delegate (enables foreground push banners via UNUserNotificationCenter).
    UNUserNotificationCenter.current().delegate = self

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // ── FlutterImplicitEngineBridge ──────────────────────────────────────────

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    // Register all Flutter plugins (auto-generated).
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    // Register the NativeSettings MethodChannel.
    // Channel name must match native_settings.dart: 'com.leasy.ops/settings'.
    let messenger = engineBridge.binaryMessenger
    let channel = FlutterMethodChannel(
      name: "com.leasy.ops/settings",
      binaryMessenger: messenger
    )

    channel.setMethodCallHandler { (call, result) in
      switch call.method {
      case "openLocationPermission":
        // On iOS there is no direct "location permission" deeplink — the
        // standard approach is to open the app's own Settings page where
        // the user can change Location access to "Always".
        if let url = URL(string: UIApplication.openSettingsURLString) {
          UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  // ── APNs / FCM token forwarding ──────────────────────────────────────────

  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    // Forward APNs token to Firebase Messaging so it can produce an FCM token.
    Messaging.messaging().apnsToken = deviceToken
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }
}
