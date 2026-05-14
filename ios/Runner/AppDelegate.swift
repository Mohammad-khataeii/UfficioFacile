import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let screenProtectionCoordinator = ScreenProtectionCoordinator()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let didFinish = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "ufficiofacile/screen_protection",
        binaryMessenger: controller.binaryMessenger
      )
      channel.setMethodCallHandler { [weak self] call, result in
        guard call.method == "setSecureScreen" else {
          result(FlutterMethodNotImplemented)
          return
        }
        let args = call.arguments as? [String: Any]
        let enabled = args?["enabled"] as? Bool ?? false
        self?.screenProtectionCoordinator.setEnabled(enabled)
        result(nil)
      }
    }
    return didFinish
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}

final class ScreenProtectionCoordinator {
  private var enabled = false
  private var overlayWindow: UIWindow?
  private var observersInstalled = false

  func setEnabled(_ enabled: Bool) {
    self.enabled = enabled
    installObserversIfNeeded()
    updateOverlayVisibility()
  }

  private func installObserversIfNeeded() {
    guard !observersInstalled else { return }
    observersInstalled = true
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(updateOverlayVisibility),
      name: UIScreen.capturedDidChangeNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(updateOverlayVisibility),
      name: UIApplication.willResignActiveNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(updateOverlayVisibility),
      name: UIApplication.didBecomeActiveNotification,
      object: nil
    )
  }

  @objc private func updateOverlayVisibility() {
    DispatchQueue.main.async {
      guard self.enabled else {
        self.overlayWindow?.isHidden = true
        return
      }
      let shouldObscure =
        UIScreen.main.isCaptured || UIApplication.shared.applicationState != .active
      guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
        return
      }
      if self.overlayWindow == nil {
        let window = UIWindow(windowScene: scene)
        window.windowLevel = .alert + 1
        window.backgroundColor = .black
        window.rootViewController = UIViewController()
        self.overlayWindow = window
      }
      self.overlayWindow?.frame = scene.coordinateSpace.bounds
      self.overlayWindow?.isHidden = !shouldObscure
    }
  }
}
