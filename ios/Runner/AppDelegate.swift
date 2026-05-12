import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    let ok = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "evo_payment_channel",
        binaryMessenger: controller.binaryMessenger
      )
      channel.setMethodCallHandler { call, result in
        switch call.method {
        case "startPayment", "startRefund":
          result(
            FlutterError(
              code: "IOS_PAYMENT_NOT_SUPPORTED",
              message: "iOS payment not supported",
              details: nil
            )
          )
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return ok
  }
}
