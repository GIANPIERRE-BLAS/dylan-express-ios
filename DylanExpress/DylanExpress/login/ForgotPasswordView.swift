struct ForgotPasswordView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var isLoading = false
    @State private var emailSent = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        ZStack {
            (isDarkMode ? Color.black : Color.white)
                .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(spacing: 30) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 100))
                        .foregroundStyle(primaryGradient)
                        .padding(.top, 60)

                    VStack(spacing: 8) {
                        Text("Recuperar Contraseña")
                            .font(.title.bold())
                            .foregroundColor(isDarkMode ? .white : .black)

                        Text("Te enviaremos un enlace para restablecer tu contraseña")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Correo Electrónico")
                            .font(.subheadline.bold())
                            .foregroundColor(.gray)

                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundStyle(primaryGradient)
                            TextField("ejemplo@correo.com", text: $email)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                                .foregroundColor(isDarkMode ? .white : .black)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(primaryGradient, lineWidth: 1.7)
                        )
                    }
                    .padding(.horizontal, 25)

                    if showError {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        .padding(.horizontal, 25)
                    }

                    VStack(spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                            Text("Ingresa tu correo registrado")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }

                        HStack(spacing: 8) {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.green)
                            Text("Recibirás un enlace de recuperación")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }

                        HStack(spacing: 8) {
                            Image(systemName: "lock.rotation")
                                .foregroundColor(.orange)
                            Text("Restablece tu contraseña de forma segura")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, 25)

                    Button(action: {
                        sendPasswordReset()
                    }) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            HStack {
                                Image(systemName: "paperplane.fill")
                                Text("ENVIAR ENLACE")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(email.isEmpty ? AnyShapeStyle(Color.gray) : AnyShapeStyle(primaryGradient))
                    .cornerRadius(16)
                    .padding(.horizontal, 25)
                    .disabled(email.isEmpty || isLoading)

                    Spacer(minLength: 50)
                }
            }
            .blur(radius: (isLoading || emailSent) ? 3 : 0)

            if isLoading {
                ZStack {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)

                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                            .scaleEffect(1.5)

                        Text("Enviando correo...")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                    }
                    .padding(40)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .foregroundColor(isDarkMode ? Color.gray.opacity(0.95) : Color.white)
                            .shadow(radius: 20)
                    )
                }
                .transition(.opacity)
            }

            if emailSent {
                ZStack {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)

                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.green)

                        Text("¡Correo Enviado!")
                            .font(.title.bold())
                            .foregroundColor(isDarkMode ? .white : .black)

                        Text("Revisa tu bandeja de entrada y la carpeta de spam")
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        Text(email)
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 40)
                            .multilineTextAlignment(.center)

                        Button(action: {
                            dismiss()
                        }) {
                            Text("Atrás")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(primaryGradient)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 30)
                        .padding(.top, 10)
                    }
                    .padding(40)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .foregroundColor(isDarkMode ? Color.gray.opacity(0.95) : Color.white)
                            .shadow(radius: 20)
                    )
                    .padding(.horizontal, 30)
                }
                .transition(.opacity)
            }
        }
        .navigationTitle("Recuperar Contraseña")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(isLoading || emailSent)
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }

    func sendPasswordReset() {
        guard !email.isEmpty else { return }

        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)

        if !emailPredicate.evaluate(with: email) {
            errorMessage = "Por favor ingresa un correo electrónico válido"
            showError = true
            return
        }

        showError = false
        isLoading = true

        Auth.auth().sendPasswordReset(withEmail: email) { error in
            isLoading = false

            if let error = error {
                errorMessage = getErrorMessage(error)
                showError = true
            } else {
                emailSent = true
            }
        }
    }

    func getErrorMessage(_ error: Error) -> String {
        let nsError = error as NSError

        switch nsError.code {
        case 17011:
            return "No existe una cuenta con este correo electrónico"
        case 17008:
            return "El correo electrónico no es válido"
        case 17020:
            return "Error de conexión. Verifica tu internet"
        default:
            return "Ocurrió un error. Por favor intenta de nuevo"
        }
    }
}
