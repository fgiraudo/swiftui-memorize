import SwiftUI

internal struct CardView: View {
    internal let card: MemoryGame<String>.Card
    
    private let shape = RoundedRectangle(cornerRadius: 10.0)
    
    internal var body: some View {
        ZStack {
            if card.isFaceUp {
                shape.fill(Color.white)
                shape.strokeBorder(lineWidth: 3)
                Text(card.content)
            } else if card.isMatched {
                shape.opacity(0)
            } else {
                shape.fill()
            }
        }
    }
}
