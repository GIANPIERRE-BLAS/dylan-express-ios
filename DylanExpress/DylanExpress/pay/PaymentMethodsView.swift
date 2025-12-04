import SwiftUI

struct PaymentMethodsView: View {
    let bookingId: String
    let origin: String
    let destination: String
    let date: Date
    let time: String
    let seatNumber: Int
    let price: Double
    
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    VStack(spacing: 15) {
                        Image(systemName: "creditcard.circle.fill")
                            .font(.system(size: 70))
                            .foregroundColor(Color(red: 0.0, green: 0.78, blue: 0.58))
                        
                        Text("Selecciona tu método de pago")
                            .font(.title2.bold())
                        
                        Text("Total: S/ \(String(format: "%.2f", price))")
                            .font(.title.bold())
                            .foregroundColor(Color(red: 0.0, green: 0.78, blue: 0.58))
                    }
                    .padding(.top, 30)
                    
                    VStack(spacing: 12) {
                        Text("Resumen del viaje")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: 10) {
                            SummaryRow(icon: "arrow.right", label: "Ruta", value: "\(origin) → \(destination)")
                            SummaryRow(icon: "calendar", label: "Fecha", value: formatDate(date))
                            SummaryRow(icon: "clock", label: "Hora", value: time)
                            SummaryRow(icon: "airline.seat.recline.normal", label: "Asiento", value: "Nº \(seatNumber)")
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.gray.opacity(0.05))
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    VStack(spacing: 15) {
                        Text("Métodos de pago")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                        
                        NavigationLink(destination: YapePaymentView(
                            bookingId: bookingId,
                            origin: origin,
                            destination: destination,
                            date: date,
                            time: time,
                            seatNumber: seatNumber,
                            price: price
                        ).environmentObject(viewModel)) {
                            PaymentMethodCard(
                                icon: "app.fill",
                                title: "Yape",
                                subtitle: "Pago rápido y seguro",
                                color: Color.purple
                            )
                        }
                        
                        NavigationLink(destination: CardPaymentView(
                            bookingId: bookingId,
                            origin: origin,
                            destination: destination,
                            date: date,
                            time: time,
                            seatNumber: seatNumber,
                            price: price
                        ).environmentObject(viewModel)) {
                            PaymentMethodCard(
                                icon: "creditcard.fill",
                                title: "Tarjeta de Crédito/Débito",
                                subtitle: "Visa, Mastercard, Amex",
                                color: Color.blue
                            )
                        }
                        
                        NavigationLink(destination: CashPaymentView(
                            bookingId: bookingId,
                            origin: origin,
                            destination: destination,
                            date: date,
                            time: time,
                            seatNumber: seatNumber,
                            price: price
                        ).environmentObject(viewModel)) {
                            PaymentMethodCard(
                                icon: "banknote.fill",
                                title: "Efectivo",
                                subtitle: "Pagar en agencia",
                                color: Color.green
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 30)
                }
            }
        }
        .navigationTitle("Método de Pago")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct PaymentMethodCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(color.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.black)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
        )
    }
}

struct SummaryRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 25)
            Text(label)
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.subheadline.bold())
        }
    }
}
