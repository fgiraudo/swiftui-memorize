import SwiftUI

internal struct GameView: View {
    @ObservedObject
    internal var viewModel: EmojiMemoryGame
    
    @Binding
    internal var presentedAsModal: Bool
    
    internal var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Text("Memorize!")
                        .font(.system(size: 32))
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 65))]) {
                        ForEach(viewModel.cards) { card in
                            CardView(card: card)
                                .aspectRatio(2/3, contentMode: .fit)
                                .onTapGesture {
                                    viewModel.choose(card: card)
                                }
                        }
                    }
                }
            }
            .padding()
            .foregroundColor(.orange)
            .font(.largeTitle)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button("Switch Theme") {
                        viewModel.switchTheme()
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button("Finish Game") {
                        self.presentedAsModal = false
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(viewModel: EmojiMemoryGame(), presentedAsModal: .constant(true))
            .preferredColorScheme(.dark)
        GameView(viewModel: EmojiMemoryGame(), presentedAsModal: .constant(true))
            .preferredColorScheme(.light)
    }
}
