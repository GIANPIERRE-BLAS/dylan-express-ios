import SwiftUI
import FirebaseCore

@main
struct DylanExpressApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var authViewModel = AuthViewModel()
    @State private var showSplash = true
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                Color.white.ignoresSafeArea()
                
                if showSplash {
                    SplashView(isActive: $showSplash)
                } else {
                    ContentView()
                        .environmentObject(authViewModel)
                }
            }
        }
    }
}
