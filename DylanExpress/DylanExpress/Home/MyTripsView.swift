import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct MyTripsView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var bookings: [BookingData] = []
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            if isLoading {
                ProgressView("Cargando viajes...")
                    .tint(Color(red: 0.0, green: 0.78, blue: 0.58))
                    .scaleEffect(1.2)
            } else if bookings.isEmpty {
                VStack(spacing: 20) {
                    Spacer()
                    Image(systemName: "bus.fill")
                        .font(.system(size: 70))
                        .foregroundStyle(AppColors.primaryGradient)
                    Text("No tienes viajes reservados")
                        .font(.title3)
                        .foregroundColor(.gray)
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 18) {
                        ForEach(bookings) { booking in
                            TripCardWithActions(booking: booking)
                                .environmentObject(viewModel)
                        }
                    }
                    .padding()
                }
                .refreshable { loadBookings() }
            }
        }
        .navigationTitle("Mis Viajes")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { loadBookings() }
    }
    
    private func loadBookings() {
        guard let userId = viewModel.userSession?.uid else { return }
        isLoading = true
        
        Firestore.firestore()
            .collection("bookings")
            .whereField("userId", isEqualTo: userId)
            .whereField("status", in: ["pending", "paid"])
            .getDocuments { snapshot, _ in
                isLoading = false
                
                if let docs = snapshot?.documents {
                    bookings = docs.compactMap { doc in
                        let data = doc.data()
                        
                        guard let userId = data["userId"] as? String,
                              let origin = data["origin"] as? String,
                              let destination = data["destination"] as? String,
                              let timestamp = data["date"] as? Timestamp,
                              let time = data["time"] as? String,
                              let seatNumber = data["seatNumber"] as? Int,
                              let price = data["price"] as? Double,
                              let status = data["status"] as? String,
                              let paymentMethod = data["paymentMethod"] as? String,
                              let created = data["createdAt"] as? Timestamp else { return nil }
                        
                        let placeType = data["placeType"] as? String
                        let travelType = data["travelType"] as? String
                        let numberOfPeople = data["numberOfPeople"] as? Int
                        
                        return BookingData(
                            id: doc.documentID,
                            userId: userId,
                            origin: origin,
                            destination: destination,
                            date: timestamp.dateValue(),
                            time: time,
                            seatNumber: seatNumber,
                            status: status,
                            price: price,
                            paymentMethod: paymentMethod,
                            createdAt: created.dateValue(),
                            isTouristPlace: placeType == "tourist",
                            travelType: travelType,
                            numberOfPeople: numberOfPeople
                        )
                    }
                    
                    bookings.sort { $0.createdAt > $1.createdAt }
                }
            }
    }
}

struct TripCardWithActions: View {
    let booking: BookingData
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var showShareSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 18) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(booking.origin)
                            .font(.title3.bold())
                        Text(booking.time)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Image(systemName: booking.isTouristPlace ? "camera.viewfinder" : "arrow.right")
                        .font(.title2)
                        .foregroundStyle(AppColors.primaryGradient)
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(booking.destination)
                            .font(.title3.bold())
                        Text(booking.dateString)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Divider()
                
                HStack {
                    if booking.isTouristPlace {
                        Label("\(booking.numberOfPeople ?? 1) persona(s)", systemImage: "person.3.fill")
                            .font(.subheadline.bold())
                            .foregroundStyle(AppColors.primaryGradient)
                    } else {
                        Label("Asiento \(booking.seatNumber)", systemImage: "airline.seat.recline.normal")
                            .font(.subheadline.bold())
                            .foregroundStyle(AppColors.primaryGradient)
                    }
                    Spacer()
                    HStack(spacing: 6) {
                        Circle()
                            .fill(booking.status == "paid" ? Color.green : Color.orange)
                            .frame(width: 9, height: 9)
                        Text(booking.status == "paid" ? "Pagado" : "Pendiente")
                            .font(.caption.bold())
                            .foregroundColor(booking.status == "paid" ? .green : .orange)
                    }
                }
                
                HStack {
                    Text("Total: S/ \(String(format: "%.2f", booking.price))")
                        .font(.headline)
                        .foregroundStyle(AppColors.primaryGradient)
                    Spacer()
                    if booking.isTouristPlace {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(Color(red: 1, green: 0.85, blue: 0.0))
                        Text("Tour")
                            .font(.caption.bold())
                            .foregroundColor(Color(red: 1, green: 0.85, blue: 0.0))
                    }
                }
            }
            .padding()
            
            Divider()
            
            HStack(spacing: 12) {
                NavigationLink(destination: TicketDetailView(bookingId: booking.id)
                    .environmentObject(viewModel)) {
                    Label("Ver Boleto", systemImage: "ticket.fill")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppColors.primaryGradient)
                        .cornerRadius(12)
                }
                
                Button {
                    showShareSheet = true
                } label: {
                    Label("Compartir", systemImage: "square.and.arrow.up")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppColors.primaryGradient.opacity(0.9))
                        .cornerRadius(12)
                }
                .sheet(isPresented: $showShareSheet) {
                    ShareSheet(activityItems: [generateTicketImage()])
                }
                
                if booking.status == "pending" {
                    if booking.paymentMethod == "cash" {
                        Button {} label: {
                            Label("Pagar en Agencia", systemImage: "building.2.fill")
                                .font(.subheadline.bold())
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.orange)
                                .cornerRadius(12)
                        }
                    } else {
                        NavigationLink(destination: PaymentMethodsView(
                            bookingId: booking.id,
                            origin: booking.origin,
                            destination: booking.destination,
                            date: booking.date,
                            time: booking.time,
                            seatNumber: booking.seatNumber,
                            price: booking.price
                        ).environmentObject(viewModel)) {
                            Label("Pagar Ahora", systemImage: "creditcard.fill")
                                .font(.subheadline.bold())
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.green)
                                .cornerRadius(12)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 12)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColors.primaryGradient, lineWidth: 2)
                .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
    
    private func generateTicketImage() -> UIImage {
        let ticket = TicketForShare(booking: booking)
        let controller = UIHostingController(rootView: ticket)
        let view = controller.view!
        
        let size = CGSize(width: 400, height: 620)
        view.bounds = CGRect(origin: .zero, size: size)
        view.backgroundColor = UIColor.systemGroupedBackground
        
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
    }
}

struct TicketForShare: View {
    let booking: BookingData
    
    var body: some View {
        VStack(spacing: 25) {
            Text(booking.isTouristPlace ? "TICKET TURÍSTICO" : "BOLETO DE VIAJE")
                .font(.title.bold())
                .foregroundStyle(AppColors.primaryGradient)
            
            VStack(alignment: .leading, spacing: 16) {
                row("Origen", booking.origin)
                row("Destino", booking.destination)
                row("Fecha", booking.dateString)
                row("Hora", booking.time)
                
                if booking.isTouristPlace {
                    row("Personas", "\(booking.numberOfPeople ?? 1)")
                    if let type = booking.travelType {
                        row("Tipo", type)
                    }
                } else {
                    row("Asiento", "\(booking.seatNumber)")
                }
                
                row("Total", "S/ \(String(format: "%.2f", booking.price))")
                    .foregroundStyle(AppColors.primaryGradient)
            }
            .font(.title3)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(30)
            .background(Color.white)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(AppColors.primaryGradient, lineWidth: 4)
            )
        }
        .padding(30)
    }
    
    private func row(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title + ":")
            Spacer()
            Text(value).bold()
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct AppColors {
    static let primaryGradient = LinearGradient(
        colors: [
            Color(red: 1, green: 0.85, blue: 0.0),
            Color(red: 0.0, green: 0.78, blue: 0.58),
            Color(red: 0.0, green: 0.68, blue: 0.95)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
}

