import SwiftUI
import FirebaseCore

@main
struct DylanExpressApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var authViewModel = AuthViewModel()
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var showSplash = true
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                (isDarkMode ? Color.black : Color.white)
                    .ignoresSafeArea()
                
                if showSplash {
                    SplashView(isActive: $showSplash)
                } else {
                    ContentView()
                        .environmentObject(authViewModel)
                }
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}
