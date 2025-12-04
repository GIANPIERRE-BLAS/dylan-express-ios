import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                VStack(spacing: 8) {
                    Image("logodylan")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 220)
                    
                    Text("Tu viaje comienza aquí")
                        .font(.title3)
                        .foregroundColor(.black.opacity(0.75))
                }
                
                VStack(spacing: 22) {
                    CustomGradientField(title: "Correo Electrónico", text: $email, icon: "envelope")
                    CustomGradientSecureField(title: "Contraseña", text: $password, icon: "lock")
                }
                .padding(.horizontal, 35)
                
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal, 35)
                }
                
                Button {
                    viewModel.login(email: email, password: password)
                } label: {
                    if viewModel.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("INICIAR SESIÓN")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(primaryGradient)
                .cornerRadius(16)
                .padding(.horizontal, 35)
                .disabled(viewModel.isLoading || email.isEmpty || password.isEmpty)
                
                HStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 1)
                    Text("O")
                        .foregroundColor(.gray)
                        .padding(.horizontal, 8)
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 1)
                }
                .padding(.horizontal, 35)
                
                Button {
                    viewModel.signInWithGoogle()
                } label: {
                    HStack {
                        Image(systemName: "globe")
                            .font(.title3)
                        Text("Continuar con Google")
                            .font(.headline)
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1.5)
                    )
                    .cornerRadius(16)
                }
                .padding(.horizontal, 35)
                .disabled(viewModel.isLoading)
                
                Button {
                    showRegister = true
                } label: {
                    Text("Crear nueva cuenta")
                        .foregroundColor(Color.blue)
                        .font(.callout)
                }
                
                Spacer()
            }
            
            if viewModel.userSession != nil {
                HomeView()
                    .environmentObject(viewModel)
                    .transition(.move(edge: .trailing))
            }
        }
        .fullScreenCover(isPresented: $showRegister) {
            RegisterView()
                .environmentObject(viewModel)
        }
        .onAppear {
            viewModel.userSession = Auth.auth().currentUser
        }
    }
}

struct CustomGradientField: View {
    var title: String
    @Binding var text: String
    var icon: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack {
                TextField("", text: $text)
                    .autocapitalization(.none)
                    .keyboardType(keyboardType)
                Image(systemName: icon)
                    .foregroundStyle(primaryGradient)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 16).stroke(primaryGradient, lineWidth: 1.7))
        }
    }
}

struct CustomGradientSecureField: View {
    var title: String
    @Binding var text: String
    var icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack {
                SecureField("", text: $text)
                Image(systemName: icon)
                    .foregroundStyle(primaryGradient)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 16).stroke(primaryGradient, lineWidth: 1.7))
        }
    }
}
