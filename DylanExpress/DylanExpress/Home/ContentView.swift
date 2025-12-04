import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            if viewModel.userSession != nil {
                HomeView()
                    .environmentObject(viewModel)
                    .transition(.opacity)
            } else {
                LoginView()
                    .environmentObject(viewModel)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.userSession != nil)
    }
}
