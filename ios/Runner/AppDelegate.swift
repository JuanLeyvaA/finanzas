import AppIntents
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private static let automationChannelName = "misfin/automation"
  private static let pendingTextKey = "misfin.pendingAutomationText"
  private var automationChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let url = launchOptions?[.url] as? URL {
      _ = handleAutomationURL(url)
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    guard let registrar = engineBridge.pluginRegistry.registrar(
      forPlugin: "MisFinAutomation"
    ) else {
      return
    }

    let channel = FlutterMethodChannel(
      name: Self.automationChannelName,
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "consumePendingText" else {
        result(FlutterMethodNotImplemented)
        return
      }

      let text = UserDefaults.standard.string(forKey: Self.pendingTextKey)
      UserDefaults.standard.removeObject(forKey: Self.pendingTextKey)
      result(text)
    }
    automationChannel = channel
  }

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    if handleAutomationURL(url) {
      return true
    }
    return super.application(app, open: url, options: options)
  }

  @discardableResult
  func handleAutomationURL(_ url: URL) -> Bool {
    guard url.scheme?.lowercased() == "misfin",
          let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
    else {
      return false
    }

    let acceptedKeys = ["text", "payload", "message", "raw", "clipboard", "content"]
    guard let text = components.queryItems?
      .first(where: { acceptedKeys.contains($0.name) })?
      .value?
      .trimmingCharacters(in: .whitespacesAndNewlines),
      !text.isEmpty
    else {
      return false
    }

    UserDefaults.standard.set(text, forKey: Self.pendingTextKey)
    automationChannel?.invokeMethod("incomingText", arguments: text)
    return true
  }
}

@available(iOS 16.0, *)
struct RegisterExpenseIntent: AppIntent {
  static var title: LocalizedStringResource = "Registrar gasto en MisFin"
  static var description = IntentDescription(
    "Envia el texto de un movimiento a MisFin para interpretarlo y guardarlo automaticamente."
  )
  static var openAppWhenRun = true

  @Parameter(title: "Texto del movimiento")
  var text: String

  func perform() async throws -> some IntentResult & ProvidesDialog {
    let normalized = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !normalized.isEmpty else {
      return .result(dialog: "No encontre texto para procesar.")
    }

    UserDefaults.standard.set(normalized, forKey: "misfin.pendingAutomationText")
    return .result(dialog: "MisFin recibio el movimiento.")
  }
}

@available(iOS 16.0, *)
struct MisFinShortcuts: AppShortcutsProvider {
  static var appShortcuts: [AppShortcut] {
    AppShortcut(
      intent: RegisterExpenseIntent(),
      phrases: [
        "Registrar gasto en \(.applicationName)",
        "Guardar movimiento en \(.applicationName)",
      ],
      shortTitle: "Registrar gasto",
      systemImageName: "creditcard.fill"
    )
  }
}
