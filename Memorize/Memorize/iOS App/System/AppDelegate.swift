import SwiftUI
import GameKit

internal class AppDelegate: NSObject, UIApplicationDelegate {
    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        _ = GameCenterHelper.helper
        
        return true
    }
    
    private func authenticateGameCenter() {
        GKLocalPlayer.local.authenticateHandler = { viewController, _ in
            if let vc = viewController {
                UIApplication.shared.rootViewController?.present(vc, animated: true)
                
                return
            }
            
            NotificationCenter.default
              .post(name: .authenticationChanged, object: GKLocalPlayer.local.isAuthenticated)
        }
    }
}
