import SwiftUI
import FirebaseFirestore

struct CashPaymentView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    let bookingId: String
    let origin: String
    let destination: String
    let date: Date
    let time: String
    let seatNumber: Int
    let price: Double
    
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var showConfirmation = false
    @State private var isProcessing = false
    @State private var reservationCompleted = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            (isDarkMode ? Color.black : Color.white)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Spacer()
                
                Image(systemName: "banknote.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                
                Text("Pago en Efectivo")
                    .font(.title.bold())
                    .foregroundColor(isDarkMode ? .white : .black)
                
                Text("S/ \(String(format: "%.2f", price))")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.green)
                
                VStack(spacing: 20) {
                    VStack(spacing: 15) {
                        InfoRow(icon: "building.2.fill", title: "Acércate a nuestras agencias", isDarkMode: isDarkMode)
                        InfoRow(icon: "clock.fill", title: "Horario: Lunes a Domingo 6AM - 10PM", isDarkMode: isDarkMode)
                        InfoRow(icon: "mappin.circle.fill", title: "Dirección: Oficina al costado del Arco del Porvenir", isDarkMode: isDarkMode)
                        InfoRow(icon: "exclamationmark.triangle.fill", title: "Debes pagar antes de tu viaje", color: .orange, isDarkMode: isDarkMode)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundColor(isDarkMode ? Color.gray.opacity(0.2) : Color.gray.opacity(0.05))
                    )
                    .padding(.horizontal, 25)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Instrucciones:")
                            .font(.headline)
                            .foregroundColor(isDarkMode ? .white : .black)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            InstructionRow(number: "1", text: "Guarda tu código de reserva", isDarkMode: isDarkMode)
                            InstructionRow(number: "2", text: "Acércate a la agencia", isDarkMode: isDarkMode)
                            InstructionRow(number: "3", text: "Presenta tu código y DNI", isDarkMode: isDarkMode)
                            InstructionRow(number: "4", text: "Realiza el pago en efectivo", isDarkMode: isDarkMode)
                            InstructionRow(number: "5", text: "Recibe tu boleto confirmado", isDarkMode: isDarkMode)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundColor(Color.green.opacity(0.1))
                    )
                    .padding(.horizontal, 25)
                }
                
                Button(action: {
                    processReservation()
                }) {
                    if isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("CREAR RESERVA")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .cornerRadius(16)
                .padding(.horizontal, 25)
                .disabled(isProcessing)
                
                Spacer()
            }
            .blur(radius: (isProcessing || reservationCompleted) ? 3 : 0)
            
            if isProcessing {
                ZStack {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .green))
                            .scaleEffect(1.5)
                        
                        Text("Creando reserva...")
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
            
            if reservationCompleted {
                ZStack {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.green)
                        
                        Text("¡Reserva creada!")
                            .font(.title.bold())
                            .foregroundColor(isDarkMode ? .white : .black)
                        
                        Text("Recuerda pagar en agencia")
                            .font(.subheadline)
                            .foregroundColor(.gray)
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
        }
        .navigationTitle("Efectivo")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .navigationBarBackButtonHidden(isProcessing || reservationCompleted)
    }
    
    func processReservation() {
        isProcessing = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            Firestore.firestore().collection("bookings").document(bookingId).updateData([
                "status": "pending",
                "paymentMethod": "cash"
            ]) { error in
                isProcessing = false
                
                if error == nil {
                    reservationCompleted = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    var color: Color = .gray
    let isDarkMode: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 30)
            Text(title)
                .font(.subheadline)
                .foregroundColor(isDarkMode ? .white : .black)
            Spacer()
        }
    }
}

struct InstructionRow: View {
    let number: String
    let text: String
    let isDarkMode: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Text(number)
                .font(.caption.bold())
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Circle().foregroundColor(Color.green))
            Text(text)
                .font(.subheadline)
                .foregroundColor(isDarkMode ? .white : .black)
            Spacer()
        }
    }
}
