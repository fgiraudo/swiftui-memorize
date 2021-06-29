import SwiftUI
import GameKit

internal final class MainViewModel: NSObject, ObservableObject {
    @Published
    internal var isAuthenticated = false
    
    @Published
    internal var match: GKMatch?
    
    internal override init() {
        super.init()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(authenticationChanged),
            name: .authenticationChanged,
            object: nil
        )
    }
    
    @objc private func authenticationChanged() {
        isAuthenticated = GKLocalPlayer.local.isAuthenticated
    }
}

// MARK: - Game Center
extension MainViewModel: GKTurnBasedMatchmakerViewControllerDelegate, GKInviteEventListener, GKMatchDelegate, GKLocalPlayerListener {
    func turnBasedMatchmakerViewControllerWasCancelled(_ viewController: GKTurnBasedMatchmakerViewController) {
    }
    
    func turnBasedMatchmakerViewController(_ viewController: GKTurnBasedMatchmakerViewController, didFailWithError error: Error) {
    }
    
    internal func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        let content = String(decoding: data, as: UTF8.self)
        
        print("Player \(player.displayName) pressed card containing: \(content)")
    }
    
    internal func player(_ player: GKPlayer, receivedTurnEventFor match: GKTurnBasedMatch, didBecomeActive: Bool) {
        print("Got Here!")
    }
}
