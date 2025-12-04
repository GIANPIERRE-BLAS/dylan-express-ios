import SwiftUI
import FirebaseFirestore

struct CashPaymentView: View {
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
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                Image(systemName: "banknote.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                
                Text("Pago en Efectivo")
                    .font(.title.bold())
                
                Text("S/ \(String(format: "%.2f", price))")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.green)
                
                VStack(spacing: 20) {
                    VStack(spacing: 15) {
                        InfoRow(icon: "building.2.fill", title: "Acércate a nuestras agencias")
                        InfoRow(icon: "clock.fill", title: "Horario: Lunes a Domingo 6AM - 10PM")
                        InfoRow(icon: "mappin.circle.fill", title: "Dirección: Oficina al costado del Arco del Porvenir")
                        InfoRow(icon: "exclamationmark.triangle.fill", title: "Debes pagar antes de tu viaje", color: .orange)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.gray.opacity(0.05))
                    )
                    .padding(.horizontal, 25)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Instrucciones:")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            InstructionRow(number: "1", text: "Guarda tu código de reserva")
                            InstructionRow(number: "2", text: "Acércate a la agencia")
                            InstructionRow(number: "3", text: "Presenta tu código y DNI")
                            InstructionRow(number: "4", text: "Realiza el pago en efectivo")
                            InstructionRow(number: "5", text: "Recibe tu boleto confirmado")
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.green.opacity(0.05))
                    )
                    .padding(.horizontal, 25)
                }
                
                Button {
                    processReservation()
                } label: {
                    if isProcessing {
                        ProgressView()
                            .tint(.white)
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
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.green)
                        
                        Text("Creando reserva...")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                    }
                    .padding(40)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.white)
                            .shadow(radius: 20)
                    )
                }
                .transition(.opacity)
            }
            
            if reservationCompleted {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.green)
                            .scaleEffect(reservationCompleted ? 1 : 0.5)
                            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: reservationCompleted)
                        
                        Text("¡Reserva creada!")
                            .font(.title.bold())
                            .foregroundColor(.black)
                        
                        Text("Recuerda pagar en agencia")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(40)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.white)
                            .shadow(radius: 20)
                    )
                }
                .transition(.opacity)
            }
        }
        .navigationTitle("Efectivo")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(isProcessing || reservationCompleted)
    }
    
    func processReservation() {
        withAnimation {
            isProcessing = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            Firestore.firestore().collection("bookings").document(bookingId).updateData([
                "status": "pending",
                "paymentMethod": "cash"
            ]) { error in
                withAnimation {
                    isProcessing = false
                }
                
                if error == nil {
                    withAnimation {
                        reservationCompleted = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        dismiss()
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
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 30)
            Text(title)
                .font(.subheadline)
                .foregroundColor(.black)
            Spacer()
        }
    }
}

struct InstructionRow: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(number)
                .font(.caption.bold())
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Circle().fill(Color.green))
            Text(text)
                .font(.subheadline)
                .foregroundColor(.black)
            Spacer()
        }
    }
}
