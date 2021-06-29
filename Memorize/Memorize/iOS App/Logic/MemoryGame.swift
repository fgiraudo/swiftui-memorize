import Foundation

internal struct MemoryGame<CardContent> where CardContent: Equatable, CardContent: Encodable {
    private(set) var cards: Array<Card>
    
    private var indexOfTheOneAndOnlyFaceUpCard: Int?
    
    internal init(numberOfPairsOfCards: Int, cardContentFactory: (Int) -> CardContent) {
        cards = Array<Card>()
        
        for pairIndex in 0 ..< numberOfPairsOfCards {
            let content = cardContentFactory(pairIndex)
            cards.append(Card(content: content, id: pairIndex * 2))
            cards.append(Card(content: content, id: pairIndex * 2 + 1))
        }
    }
    
    internal mutating func choose(_ card: Card) {
        guard let index = cards.firstIndex(where: { $0.id == card.id }),
              !cards[index].isFaceUp,
              !cards[index].isMatched
              else {
            return
        }
                
        if let potentialMatchIndex = indexOfTheOneAndOnlyFaceUpCard {
            if cards[index].content == cards[potentialMatchIndex].content {
                cards[index].isMatched = true
                cards[potentialMatchIndex].isMatched = true
            }
            
            indexOfTheOneAndOnlyFaceUpCard = nil
        } else {
            for index in cards.indices {
                cards[index].isFaceUp = false
            }
            
            self.indexOfTheOneAndOnlyFaceUpCard = index
        }
        
        cards[index].isFaceUp.toggle()
    }
    
    private func indexOf(_ card: Card) -> Int {
        for index in 0 ..< cards.count {
            if card.id == cards[index].id {
                return index
            }
        }
        
        return 0
    }
    
    internal mutating func shuffleCards() {
        cards = cards.shuffled()
    }
    
    internal struct Card: Identifiable, Encodable where CardContent: Encodable {
        var isFaceUp: Bool = false
        var isMatched: Bool = false
        var content: CardContent
        var id: Int
    }
}

extension MemoryGame: Encodable {}
