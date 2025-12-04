import SwiftUI

struct RootView: View {
    @State private var showSplash = true
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashView(isActive: $showSplash)
            } else {
                LoginView()
                    .transition(.opacity.animation(.easeIn(duration: 0.5)))
            }
        }
    }
}

