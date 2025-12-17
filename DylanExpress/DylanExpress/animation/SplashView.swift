import SwiftUI

struct SplashView: View {
    @Binding var isActive: Bool
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var busOffset1: CGFloat = -400
    @State private var busOffset2: CGFloat = -600
    @State private var busOffset3: CGFloat = -500
    @State private var roadLineOffset: CGFloat = 0
    @State private var locationPinsOpacity: Double = 0
    
    var body: some View {
        ZStack {
            background
            
            VStack {
                Spacer()
                
                ZStack {
                    HStack(spacing: 60) {
                        ForEach(0..<15, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 2)
                                .foregroundColor(isDarkMode ? .white.opacity(0.2) : .gray.opacity(0.3))
                                .frame(width: 40, height: 4)
                        }
                    }
                    .offset(x: roadLineOffset, y: 150)
                    
                    Image(systemName: "bus.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.green.opacity(0.6))
                        .offset(x: busOffset1, y: -100)
                    
                    Image(systemName: "bus.fill")
                        .font(.system(size: 35))
                        .foregroundColor(.blue.opacity(0.5))
                        .offset(x: busOffset2, y: 100)
                    
                    Image(systemName: "bus.fill")
                        .font(.system(size: 45))
                        .foregroundColor(.green.opacity(0.7))
                        .offset(x: busOffset3, y: 0)
                    
                    ForEach(0..<4, id: \.self) { index in
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 25))
                            .foregroundColor(index % 2 == 0 ? .green : .blue)
                            .opacity(locationPinsOpacity)
                            .offset(
                                x: CGFloat(index - 2) * 120,
                                y: CGFloat(index % 2 == 0 ? -80 : 80)
                            )
                    }
                    
                    Image("logodylan")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 280)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                }
                
                Spacer()
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onAppear {
            startAnimations()
        }
    }
    
    private var background: some View {
        ZStack {
            LinearGradient(
                colors: isDarkMode
                    ? [Color.black, Color(red: 0.1, green: 0.1, blue: 0.15)]
                    : [Color(red: 0.95, green: 0.97, blue: 1.0), Color.white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .ignoresSafeArea()
    }
    
    private func startAnimations() {
        withAnimation(.spring(response: 1.0, dampingFraction: 0.7)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
            roadLineOffset = -1200
        }
        
        withAnimation(.easeInOut(duration: 2.5)) {
            busOffset1 = 400
        }
        
        withAnimation(.easeInOut(duration: 3.0).delay(0.3)) {
            busOffset2 = 500
        }
        
        withAnimation(.easeInOut(duration: 2.8).delay(0.5)) {
            busOffset3 = 450
        }
        
        withAnimation(.easeOut(duration: 0.8).delay(0.5)) {
            locationPinsOpacity = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            withAnimation(.easeInOut(duration: 0.5)) {
                logoScale = 0.7
                logoOpacity = 0
                locationPinsOpacity = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isActive = false
            }
        }
    }
}
