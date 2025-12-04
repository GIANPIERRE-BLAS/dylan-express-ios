import SwiftUI

struct TripCard: View {
    let booking: BookingData
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var showTicket = false

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 15) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(booking.origin)
                            .font(.title3.bold())
                        Text(booking.time)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Image(systemName: "arrow.right")
                        .foregroundColor(Color(red: 0.0, green: 0.78, blue: 0.58))
                        .font(.title2)
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text(booking.destination)
                            .font(.title3.bold())
                        Text(booking.dateString)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                Divider()

                HStack {
                    Image(systemName: "airline.seat.recline.normal")
                        .foregroundColor(Color(red: 0.0, green: 0.78, blue: 0.58))
                    Text("Asiento \(booking.seatNumber)")
                        .font(.subheadline.bold())
                    Spacer()
                    HStack(spacing: 6) {
                        Circle()
                            .fill(booking.status == "paid" ? Color.green : Color.orange)
                            .frame(width: 10, height: 10)
                        Text(booking.status == "paid" ? "Pagado" : "Pendiente")
                            .font(.caption.bold())
                            .foregroundColor(booking.status == "paid" ? .green : .orange)
                    }
                }

                HStack {
                    Text("Total: S/ \(String(format: "%.2f", booking.price))")
                        .font(.subheadline.bold())
                        .foregroundColor(Color(red: 0.0, green: 0.78, blue: 0.58))
                    Spacer()
                }
            }
            .padding()
            
            Divider()
            
            HStack {
                if booking.status == "pending" {
                    NavigationLink(destination: PaymentMethodsView(
                        origin: booking.origin,
                        destination: booking.destination,
                        date: booking.date,
                        time: booking.time,
                        seatNumber: booking.seatNumber,
                        price: booking.price
                    ).environmentObject(viewModel)) {
                        Text("Pagar")
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.orange)
                            .cornerRadius(10)
                    }
                } else {
                    Button("Ver Ticket") {
                        showTicket = true
                    }
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(red: 0.0, green: 0.78, blue: 0.58))
                    .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.2), radius: 5, y: 2)
        )
        .sheet(isPresented: $showTicket) {
            TicketDetailView(bookingId: booking.id)
                .environmentObject(viewModel)
        }
    }
}
