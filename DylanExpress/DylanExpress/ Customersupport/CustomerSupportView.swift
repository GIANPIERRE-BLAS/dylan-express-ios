import SwiftUI

struct CustomerSupportView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var showingFAQ = false
    @State private var isLoading = true
    
    let faqItems: [FAQItem] = [
        FAQItem(question: "¿Cómo puedo reservar un pasaje?", answer: "Puedes reservar un pasaje desde la pestaña 'Buscar', seleccionando tu origen, destino, fecha y hora de viaje. Luego elige tu asiento y procede al pago."),
        FAQItem(question: "¿Puedo cancelar mi reserva?", answer: "Sí, puedes cancelar tu reserva hasta 24 horas antes de la salida. El reembolso se procesará en 5-7 días hábiles."),
        FAQItem(question: "¿Qué métodos de pago aceptan?", answer: "Aceptamos tarjetas de crédito, débito, Yape, Plin y pago en efectivo."),
        FAQItem(question: "¿Puedo cambiar la fecha de mi viaje?", answer: "Sí, puedes modificar la fecha de tu viaje hasta 12 horas antes."),
        FAQItem(question: "¿Qué debo llevar para abordar?", answer: "DNI o documento de identidad y el código de reserva."),
        FAQItem(question: "¿Cuánto equipaje puedo llevar?", answer: "1 maleta de 20kg y 1 bolso de mano de 5kg.")
    ]
    
    var body: some View {
        ZStack {
            (isDarkMode ? Color.black : Color.white)
                .edgesIgnoringSafeArea(.all)
            
            if isLoading {
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .foregroundColor(.clear)
                            .background(primaryGradient)
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                        
                        Image(systemName: "headphones.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    }
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.primaryGreen))
                    
                    Text("Cargando soporte...")
                        .font(.subheadline)
                        .foregroundColor(isDarkMode ? .white.opacity(0.7) : .gray)
                }
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 25) {
                        
                        VStack(spacing: 15) {
                            ZStack {
                                Circle()
                                    .foregroundColor(Color(red: 0.0, green: 0.78, blue: 0.58).opacity(0.2))
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: "headphones.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.blue)
                            }
                            
                            Text("¿Cómo podemos ayudarte?")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(isDarkMode ? .white : .black)
                            
                            Text("Estamos aquí para resolver todas tus dudas")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        .padding(.horizontal, 20)
                        
                        NavigationLink(destination: ComplaintsView()) {
                            HStack(spacing: 15) {
                                ZStack {
                                    Circle()
                                        .foregroundColor(Color.red.opacity(0.1))
                                        .frame(width: 50, height: 50)
                                    Image(systemName: "exclamationmark.bubble.fill")
                                        .font(.title3)
                                        .foregroundColor(.red)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Libro de Reclamaciones")
                                        .font(.headline)
                                        .foregroundColor(isDarkMode ? .white : .black)
                                    Text("Registra tu queja o reclamo")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .foregroundColor(isDarkMode ? Color.gray.opacity(0.2) : Color.white)
                            )
                            .shadow(color: isDarkMode ? .clear : .gray.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(spacing: 15) {
                            Text("Contacto Directo")
                                .font(.headline)
                                .foregroundColor(isDarkMode ? .white : .black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                            
                            ContactButtonView(
                                color: .green,
                                systemIcon: "message.fill",
                                title: "WhatsApp",
                                subtitle: "+51 914 897 970",
                                isDarkMode: isDarkMode,
                                action: { ContactActions.openWhatsApp(number: "51914897970") }
                            )
                            .padding(.horizontal, 20)
                            
                            ContactButtonView(
                                color: .blue,
                                systemIcon: "phone.fill",
                                title: "Llamar",
                                subtitle: "+51 914 897 970",
                                isDarkMode: isDarkMode,
                                action: { ContactActions.call(number: "51914897970") }
                            )
                            .padding(.horizontal, 20)
                            
                            ContactButtonView(
                                color: .orange,
                                systemIcon: "envelope.fill",
                                title: "Correo Electrónico",
                                subtitle: "hpozoguevara@gmail.com",
                                isDarkMode: isDarkMode,
                                action: { ContactActions.sendEmail(to: "hpozoguevara@gmail.com") }
                            )
                            .padding(.horizontal, 20)
                        }
                        
                        Divider()
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 15) {
                            Text("Nuestra Ubicación")
                                .font(.headline)
                                .foregroundColor(isDarkMode ? .white : .black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                            
                            HStack(spacing: 15) {
                                ZStack {
                                    Circle()
                                        .foregroundColor(Color.red.opacity(0.1))
                                        .frame(width: 50, height: 50)
                                    
                                    Image(systemName: "mappin.circle.fill")
                                        .font(.title3)
                                        .foregroundColor(.red)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Trujillo, Perú")
                                        .font(.headline)
                                        .foregroundColor(isDarkMode ? .white : .black)
                                    Text("Oficina en El Arco Porvenir")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .foregroundColor(isDarkMode ? Color.gray.opacity(0.2) : Color.white)
                            )
                            .shadow(color: isDarkMode ? .clear : .gray.opacity(0.1), radius: 5, x: 0, y: 2)
                            .padding(.horizontal, 20)
                        }
                        
                        Divider()
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 15) {
                            HStack {
                                Text("Preguntas Frecuentes")
                                    .font(.headline)
                                    .foregroundColor(isDarkMode ? .white : .black)
                                
                                Spacer()
                                
                                Button(action: {
                                    withAnimation {
                                        showingFAQ.toggle()
                                    }
                                }) {
                                    Image(systemName: showingFAQ ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                                        .foregroundColor(.blue)
                                        .font(.title3)
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            if showingFAQ {
                                VStack(spacing: 12) {
                                    ForEach(faqItems) { item in
                                        FAQCardView(item: item, isDarkMode: isDarkMode)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .transition(.opacity)
                            }
                        }
                        
                        Divider()
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 15) {
                            Text("Políticas de Cancelación")
                                .font(.headline)
                                .foregroundColor(isDarkMode ? .white : .black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                            
                            VStack(alignment: .leading, spacing: 15) {
                                PolicyItemView(icon: "checkmark.circle.fill", color: .green, title: "Cancelación con más de 24 horas", description: "Reembolso del 100% del pasaje.", isDarkMode: isDarkMode)
                                PolicyItemView(icon: "clock.fill", color: .orange, title: "Cancelación entre 12-24 horas", description: "Reembolso del 50%.", isDarkMode: isDarkMode)
                                PolicyItemView(icon: "xmark.circle.fill", color: .red, title: "Menos de 12 horas", description: "No hay reembolso.", isDarkMode: isDarkMode)
                                PolicyItemView(icon: "arrow.triangle.2.circlepath.circle.fill", color: .blue, title: "Cambio de fecha", description: "Sin costo hasta 12 horas antes.", isDarkMode: isDarkMode)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .foregroundColor(isDarkMode ? Color.gray.opacity(0.2) : Color.gray.opacity(0.05))
                            )
                            .padding(.horizontal, 20)
                        }
                        
                        VStack(spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "clock.fill")
                                    .foregroundColor(.blue)
                                
                                Text("Horario de Atención")
                                    .font(.headline)
                                    .foregroundColor(isDarkMode ? .white : .black)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("Lunes a Domingo: 6:00 AM - 10:00 PM")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .foregroundColor(isDarkMode ? Color.gray.opacity(0.2) : Color.white)
                        )
                        .shadow(color: isDarkMode ? .clear : .gray.opacity(0.1), radius: 5, x: 0, y: 2)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationTitle("Soporte al Cliente")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation {
                    isLoading = false
                }
            }
        }
    }
}

struct ContactButtonView: View {
    let color: Color
    let systemIcon: String
    let title: String
    let subtitle: String
    let isDarkMode: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                ZStack {
                    Circle()
                        .foregroundColor(color.opacity(0.1))
                        .frame(width: 50, height: 50)
                    Image(systemName: systemIcon)
                        .font(.title3)
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(isDarkMode ? .white : .black)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .foregroundColor(isDarkMode ? Color.gray.opacity(0.2) : Color.white)
            )
            .shadow(color: isDarkMode ? .clear : .gray.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
}

struct ContactActions {
    static func openWhatsApp(number: String) {
        let cleanNumber = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let urlString = "https://wa.me/\(cleanNumber)"
        guard let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
    
    static func call(number: String) {
        let cleanNumber = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        guard let url = URL(string: "tel://\(cleanNumber)"), UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
    
    static func sendEmail(to email: String) {
        guard let url = URL(string: "mailto:\(email)"), UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
}

struct FAQItem: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}

struct FAQCardView: View {
    let item: FAQItem
    let isDarkMode: Bool
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "questionmark.circle.fill")
                        .foregroundColor(.blue)
                    Text(item.question)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(isDarkMode ? .white : .black)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }
            
            if isExpanded {
                Text(item.answer)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .transition(.opacity)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(isDarkMode ? Color.gray.opacity(0.2) : Color.white)
        )
        .shadow(color: isDarkMode ? .clear : .gray.opacity(0.1), radius: 3, x: 0, y: 1)
    }
}

struct PolicyItemView: View {
    let icon: String
    let color: Color
    let title: String
    let description: String
    let isDarkMode: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
                .frame(width: 30)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(isDarkMode ? .white : .black)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
    }
}
