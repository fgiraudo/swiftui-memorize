import SwiftUI
import GameKit

@main
struct MemorizeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) internal var appDelegate
    
    var body: some Scene {
        WindowGroup {
            MainView(mainViewModel: MainViewModel())
        }
    }
}
