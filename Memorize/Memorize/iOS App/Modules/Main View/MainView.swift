import SwiftUI

internal struct MainView: View {
    @State var presentingGame = false
    @State var presentingProgressView = false
    
    @ObservedObject var mainViewModel: MainViewModel
    
    @ViewBuilder
    var body: some View {
        VStack(spacing: 30) {
            MainViewButton(title: "Local Game") {
                self.presentingGame = true
            }
            MainViewButton(title: "Online Game") {
                self.presentingProgressView = true
                
                GameCenterHelper.helper.presentMatchmaker() {
                    self.presentingProgressView = false
                    self.presentingGame = true
                }
            }
            .disabled(mainViewModel.isAuthenticated == false)
        }
        .fullScreenCover(isPresented: $presentingGame) {
            GameView(viewModel: EmojiMemoryGame(), presentedAsModal: self.$presentingGame)
        }
        .fullScreenCover(isPresented: $presentingProgressView) {
            ProgressView()
        }
    }
}

struct MainViewButton: View {
    var title: String
    var action: () -> Void
    
    var body: some View {
        Button(title) {
            action()
        }
        .font(.title)
        .padding()
        .background(Color.purple)
        .cornerRadius(40)
        .foregroundColor(.white)
        .padding(10)
        .overlay(
            RoundedRectangle(cornerRadius: 40)
                .stroke(Color.purple, lineWidth: 5)
        )
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(mainViewModel: MainViewModel())
    }
}
