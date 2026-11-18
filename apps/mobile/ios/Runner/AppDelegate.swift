import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    guard let registry = engineBridge.pluginRegistry.registrar(forPlugin: "AliceStorage") else {
      return
    }
    let storage = FlutterMethodChannel(name: "alice/storage", binaryMessenger: registry.messenger())
    storage.setMethodCallHandler { call, result in
      guard call.method == "excludeFromBackup" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard let path = call.arguments as? String else {
        result(FlutterError(code: "storage", message: "Invalid storage location", details: nil))
        return
      }
      do {
        var directory = URL(fileURLWithPath: path, isDirectory: true)
        var settings = URLResourceValues()
        settings.isExcludedFromBackup = true
        try directory.setResourceValues(settings)
        result(nil)
      } catch {
        result(FlutterError(code: "storage", message: "Could not protect app storage", details: nil))
      }
    }

  }
}
