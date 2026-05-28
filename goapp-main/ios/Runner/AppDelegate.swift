import Flutter
import UIKit
import GoogleMaps
import CoreLocation
import UserNotifications

class PermissionChannelHandler: NSObject, CLLocationManagerDelegate {
  private var locationManager: CLLocationManager?
  private var locationResult: FlutterResult?

  func requestLocationWhenInUse(_ result: @escaping FlutterResult) {
    let status = CLLocationManager.authorizationStatus()
    if status == .authorizedWhenInUse || status == .authorizedAlways {
      result("granted")
      return
    }
    if status == .denied {
      result("permanentlyDenied")
      return
    }
    locationResult = result
    let manager = CLLocationManager()
    manager.delegate = self
    locationManager = manager
    manager.requestWhenInUseAuthorization()
  }

  func locationManager(
    _ manager: CLLocationManager,
    didChangeAuthorization status: CLAuthorizationStatus
  ) {
    guard let result = locationResult else { return }
    locationResult = nil
    switch status {
    case .authorizedAlways, .authorizedWhenInUse:
      result("granted")
    case .restricted:
      result("restricted")
    case .denied:
      result("permanentlyDenied")
    default:
      result("denied")
    }
  }

  func openAppSettings() -> Bool {
    guard let url = URL(string: UIApplication.openSettingsURLString) else {
      return false
    }
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
    return true
  }

  func checkNotification(_ result: @escaping FlutterResult) {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      switch settings.authorizationStatus {
      case .authorized, .provisional:
        result("granted")
      case .denied:
        result("permanentlyDenied")
      case .restricted:
        result("restricted")
      default:
        result("denied")
      }
    }
  }

  func requestNotification(_ result: @escaping FlutterResult) {
    UNUserNotificationCenter.current().requestAuthorization(
      options: [.alert, .sound, .badge]
    ) { granted, _ in
      result(granted ? "granted" : "denied")
    }
  }

  func openNotificationSettings() -> Bool {
    return openAppSettings()
  }
}

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let permissionHandler = PermissionChannelHandler()
  private let notificationChannelName = "native_notifications"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let key = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_MAPS_API_KEY") as? String,
       !key.isEmpty {
      GMSServices.provideAPIKey(key)
    }
    GeneratedPluginRegistrant.register(with: self)

    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "native_permissions",
        binaryMessenger: controller.binaryMessenger
      )
      channel.setMethodCallHandler { [weak self] call, result in
        guard let self = self else { return }
        switch call.method {
        case "requestLocationWhenInUse":
          self.permissionHandler.requestLocationWhenInUse(result)
        case "openAppSettings":
          result(self.permissionHandler.openAppSettings())
        case "checkNotification":
          self.permissionHandler.checkNotification(result)
        case "requestNotification":
          self.permissionHandler.requestNotification(result)
        case "openNotificationSettings":
          result(self.permissionHandler.openNotificationSettings())
        default:
          result(FlutterMethodNotImplemented)
        }
      }

      let notificationsChannel = FlutterMethodChannel(
        name: notificationChannelName,
        binaryMessenger: controller.binaryMessenger
      )
      notificationsChannel.setMethodCallHandler { call, result in
        switch call.method {
        case "init":
          result(true)
        case "show":
          guard let args = call.arguments as? [String: Any] else {
            result(false)
            return
          }
          let id = args["id"] as? Int ?? 0
          let title = args["title"] as? String ?? ""
          let body = args["body"] as? String ?? ""
          self.showNotification(id: id, title: title, body: body)
          result(true)
        case "cancel":
          guard let args = call.arguments as? [String: Any] else {
            result(false)
            return
          }
          let id = args["id"] as? Int ?? 0
          self.cancelNotification(id: id)
          result(true)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func showNotification(id: Int, title: String, body: String) {
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    let request = UNNotificationRequest(
      identifier: String(id),
      content: content,
      trigger: nil
    )
    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
  }

  private func cancelNotification(id: Int) {
    let identifier = String(id)
    UNUserNotificationCenter.current().removePendingNotificationRequests(
      withIdentifiers: [identifier]
    )
    UNUserNotificationCenter.current().removeDeliveredNotifications(
      withIdentifiers: [identifier]
    )
  }
}
