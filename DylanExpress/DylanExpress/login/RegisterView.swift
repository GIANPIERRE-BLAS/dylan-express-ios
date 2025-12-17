import SwiftUI

struct RegisterView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var fullName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var dni = ""
    @State private var password = ""
    @State private var showSuccessAlert = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            (isDarkMode ? Color.black : Color.white)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    Spacer()
                        .frame(height: 40)
                    
                    VStack(spacing: 8) {
                        Image("logodylan")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 220)
                        
                        Text("Crea tu cuenta")
                            .font(.title3)
                            .foregroundColor(isDarkMode ? .white.opacity(0.75) : .black.opacity(0.75))
                    }
                    
                    VStack(spacing: 22) {
                        CustomGradientField(
                            title: "Nombre Completo",
                            text: $fullName,
                            icon: "person",
                            isDarkMode: isDarkMode
                        )
                        
                        CustomGradientField(
                            title: "DNI",
                            text: $dni,
                            icon: "creditcard",
                            keyboardType: .numberPad,
                            isDarkMode: isDarkMode
                        )
                        
                        CustomGradientField(
                            title: "Correo Electrónico",
                            text: $email,
                            icon: "envelope",
                            keyboardType: .emailAddress,
                            isDarkMode: isDarkMode
                        )
                        
                        CustomGradientField(
                            title: "Teléfono",
                            text: $phone,
                            icon: "phone",
                            keyboardType: .phonePad,
                            isDarkMode: isDarkMode
                        )
                        
                        CustomGradientSecureField(
                            title: "Contraseña",
                            text: $password,
                            icon: "lock",
                            isDarkMode: isDarkMode
                        )
                    }
                    .padding(.horizontal, 35)
                    
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.horizontal, 35)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button {
                        viewModel.register(
                            email: email,
                            password: password,
                            fullName: fullName,
                            dni: dni,
                            phone: phone
                        )
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("REGISTRARME")
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(primaryGradient)
                    .cornerRadius(16)
                    .padding(.horizontal, 35)
                    .disabled(viewModel.isLoading || !isFormValid)
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("Volver")
                            .foregroundColor(.blue)
                            .font(.callout)
                    }
                    
                    Spacer()
                        .frame(height: 40)
                }
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onChange(of: viewModel.registrationSuccess) { success in
            if success {
                showSuccessAlert = true
            }
        }
        .alert("¡Registro Exitoso!", isPresented: $showSuccessAlert) {
            Button("Iniciar Sesión") {
                viewModel.registrationSuccess = false
                dismiss()
            }
        } message: {
            Text("Tu cuenta ha sido creada. Ahora puedes iniciar sesión con tus credenciales.")
        }
    }
    
    private var isFormValid: Bool {
        return !fullName.isEmpty &&
               !dni.isEmpty &&
               !email.isEmpty &&
               !phone.isEmpty &&
               !password.isEmpty &&
               password.count >= 6
    }
}
