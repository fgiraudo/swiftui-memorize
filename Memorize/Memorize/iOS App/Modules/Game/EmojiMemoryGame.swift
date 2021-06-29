import GameKit

internal final class EmojiMemoryGame: NSObject, ObservableObject {
    @Published
    private var memoryGame: MemoryGame<String> = EmojiMemoryGame.createMemoryGame(theme: .sports)
    
    private var match: GKTurnBasedMatch?
    
    private var theme: Themes = .sports
    
    internal static func createMemoryGame(theme: Themes) -> MemoryGame<String> {
        let emojis = theme.emojis
        
        return MemoryGame<String>(numberOfPairsOfCards: 16) { pairIndex in
            emojis[pairIndex]
        }
    }
    
    // MARK: - Access to the Model
    internal var cards: Array<MemoryGame<String>.Card> {
        memoryGame.cards
    }
    
    // MARK: - Intent(s)
    internal func choose(card: MemoryGame<String>.Card) {
        memoryGame.choose(card)
        
        // broadcastCardChosen(content: card.content)
    }
    
//    private func broadcastCardChosen(content: String) {
//        /// Send a text message from one player to another.
//        func sendMessage(){
//            do {
//                let data: Data? = content.data(using: .utf8)
//
//                try match?.sendData(toAllPlayers: data!, with: GKMatch.SendDataMode.reliable)
//            } catch {
//                return
//            }
//        }
//    }
    
    internal func switchTheme() {
        theme = theme.next()
        
        memoryGame = EmojiMemoryGame.createMemoryGame(theme: theme)
        
        memoryGame.shuffleCards()
    }
}

extension EmojiMemoryGame: GKLocalPlayerListener {
    internal func player(_ player: GKPlayer, receivedTurnEventFor match: GKTurnBasedMatch, didBecomeActive: Bool) {
        
    }
}
