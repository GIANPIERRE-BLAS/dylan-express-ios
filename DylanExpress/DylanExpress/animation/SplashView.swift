import SwiftUI

struct SplashView: View {
    
    @Binding var isActive: Bool
    @State private var scale: CGFloat = 0.6
    @State private var opacity: Double = 0.0
    
    var body: some View {
        
        ZStack {
            Color.white.ignoresSafeArea()
            
            Image("logodylan")
                .resizable()
                .scaledToFit()
                .frame(width: 260)
                .scaleEffect(scale)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.1)) {
                        scale = 1.1
                        opacity = 1.0
                    }
                    
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.35)) {
                        scale = 1.0
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                        withAnimation(.easeOut(duration: 0.4)) {
                            opacity = 0.0
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            isActive = false
                        }
                    }
                }
        }
    }
}

