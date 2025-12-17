import SwiftUI

struct RootView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var showSplash = true
    
    var body: some View {
        ZStack {
            (isDarkMode ? Color.black : Color.white)
                .ignoresSafeArea()
            
            if showSplash {
                SplashView(isActive: $showSplash)
            } else {
                LoginView()
                    .transition(.opacity.animation(.easeIn(duration: 0.5)))
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}
