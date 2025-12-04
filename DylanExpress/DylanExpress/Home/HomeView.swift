import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct HomeView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                SearchTicketsView()
                    .environmentObject(viewModel)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Label("Buscar", systemImage: "magnifyingglass")
            }
            .tag(0)
            
            NavigationView {
                MyTripsView()
                    .environmentObject(viewModel)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Label("Mis Viajes", systemImage: "bus.fill")
            }
            .tag(1)
            
            NavigationView {
                CustomerSupportView()
                    .environmentObject(viewModel)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Label("Soporte", systemImage: "headphones.circle.fill")
            }
            .tag(2)
            
            NavigationView {
                ProfileView()
                    .environmentObject(viewModel)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Label("Perfil", systemImage: "person.circle.fill")
            }
            .tag(3)
        }
        .accentColor(Color(red: 0.0, green: 0.78, blue: 0.58))
    }
}
