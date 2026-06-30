import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    if let url = connectionOptions.urlContexts.first?.url,
       let delegate = UIApplication.shared.delegate as? AppDelegate {
      _ = delegate.handleAutomationURL(url)
    }
    super.scene(
      scene,
      willConnectTo: session,
      options: connectionOptions
    )
  }

  override func scene(
    _ scene: UIScene,
    openURLContexts URLContexts: Set<UIOpenURLContext>
  ) {
    let handled = URLContexts.contains { context in
      guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
        return false
      }
      return delegate.handleAutomationURL(context.url)
    }

    if !handled {
      super.scene(scene, openURLContexts: URLContexts)
    }
  }
}
