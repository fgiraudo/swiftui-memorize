import GameKit

final class GameCenterHelper: NSObject {
    typealias CompletionBlock = (Error?) -> Void
    
    static let helper = GameCenterHelper()
    
    static var isAuthenticated: Bool {
        return GKLocalPlayer.local.isAuthenticated
    }
    
    var viewController: UIViewController?
    var currentMatchmakerVC: GKTurnBasedMatchmakerViewController?
    
    var matchMakerCompletion: (() -> Void)?
    
    enum GameCenterHelperError: Error {
        case matchNotFound
        case opponentNotFound
    }
    
    var currentMatch: GKTurnBasedMatch? {
        didSet {
            print("Got here!")
        }
    }
    
    var canTakeTurnForCurrentMatch = true
    
    var currentParticipant: GKTurnBasedParticipant? {
        currentMatch?.currentParticipant
    }
    
    var nextParticipant: GKTurnBasedParticipant? {
        currentMatch?.participants.first { $0 != currentParticipant }
    }
    
    override init() {
        super.init()
        
        GKLocalPlayer.local.authenticateHandler = { gcAuthVC, error in
            NotificationCenter.default.post(name: .authenticationChanged, object: GKLocalPlayer.local.isAuthenticated)
            
            if GKLocalPlayer.local.isAuthenticated {
                GKLocalPlayer.local.register(self)
            } else if let vc = gcAuthVC {
                self.viewController?.present(vc, animated: true)
            }
            else {
                print("Error authentication to GameCenter: \(error?.localizedDescription ?? "none")")
            }
        }
    }
    
    func presentMatchmaker(completion: @escaping () -> Void) {
        guard GKLocalPlayer.local.isAuthenticated else {
            return
        }
        
        self.matchMakerCompletion = completion
        
        let request = GKMatchRequest()
        
        request.minPlayers = 2
        request.maxPlayers = 2
        request.inviteMessage = "Would you like to play Nine Knights?"
        
        let vc = GKTurnBasedMatchmakerViewController(matchRequest: request)
        vc.turnBasedMatchmakerDelegate = self
        UIApplication.shared.rootViewController?.present(vc, animated: true)
        
        currentMatchmakerVC = vc
        viewController?.present(vc, animated: true)
    }
    
//    func createMatchRequest(action: @escaping () -> Void) {
////        let request = GKMatchRequest()
////        request.minPlayers = 2
////        request.maxPlayers = 10
////
////        let vc = GKTurnBasedMatchmakerViewController(matchRequest: request)
////        vc.turnBasedMatchmakerDelegate = self
////        // UIApplication.shared.rootViewController?.present(vc, animated: true)
////
////        GKMatchmaker.shared().findMatch(for: request) { [weak self] match, error in
////            match?.delegate = self
////
////            print("Match: \(match.debugDescription)")
////
////            action()
////        }
//    }
    
    func endTurn(_ model: MemoryGame<String>, completion: @escaping CompletionBlock) {
        guard let match = currentMatch else {
            completion(GameCenterHelperError.matchNotFound)
            return
        }
        
        guard let nextParticipant = match.participants.first(where: { $0 != match.currentParticipant }) else {
            completion(GameCenterHelperError.opponentNotFound)
            return
        }
        
        canTakeTurnForCurrentMatch = false
        
        do {
            match.endTurn(
                withNextParticipants: [nextParticipant],
                turnTimeout: GKExchangeTimeoutDefault,
                match: try JSONEncoder().encode(model),
                completionHandler: completion
            )
        } catch {
            completion(error)
        }
    }
    
    func win(completion: @escaping CompletionBlock) {
        guard let match = currentMatch else {
            completion(GameCenterHelperError.matchNotFound)
            return
        }
        
        match.currentParticipant?.matchOutcome = .won
        
        for index in match.participants.indices {
            if match.participants[index] != match.currentParticipant {
                match.participants[index].matchOutcome = .lost
            }
        }
        
        match.endMatchInTurn(
            withMatch: match.matchData ?? Data(),
            completionHandler: completion
        )
    }
}

extension GameCenterHelper: GKTurnBasedMatchmakerViewControllerDelegate {
    func turnBasedMatchmakerViewControllerWasCancelled(_ viewController: GKTurnBasedMatchmakerViewController) {
        viewController.dismiss(animated: true)
    }
    
    func turnBasedMatchmakerViewController(_ viewController: GKTurnBasedMatchmakerViewController, didFailWithError error: Error) {
        print("Matchmaker vc did fail with error: \(error.localizedDescription).")
    }
}

extension GameCenterHelper: GKLocalPlayerListener, GKMatchDelegate {
    func player(_ player: GKPlayer, wantsToQuitMatch match: GKTurnBasedMatch) {
        match.currentParticipant?.matchOutcome = .lost
        
        match.participants.forEach { participant in
            if participant != match.currentParticipant {
                participant.matchOutcome = .won
            }
        }
        
        match.endMatchInTurn(
            withMatch: match.matchData ?? Data()
        )
    }
    
    func player(_ player: GKPlayer, receivedTurnEventFor match: GKTurnBasedMatch, didBecomeActive: Bool) {
        if let vc = currentMatchmakerVC {
            currentMatchmakerVC = nil
            vc.dismiss(animated: true)
        }
        
        guard didBecomeActive else {
            return
        }
        
        canTakeTurnForCurrentMatch = true
        
        NotificationCenter.default.post(name: .presentGame, object: match)
    }
    
    func turnBasedMatchmakerViewController(_ viewController: GKTurnBasedMatchmakerViewController, didFind match: GKTurnBasedMatch) {
        print("Here")
    }
}

