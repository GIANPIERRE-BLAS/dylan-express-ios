import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct MyTripsView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    @State private var bookings: [BookingData] = []
    @State private var isLoading = true
    @State private var favoriteIds: Set<String> = []
    
    var body: some View {
        ZStack {
            (isDarkMode ? Color.black : Color.white)
                .ignoresSafeArea()
            
            if isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.primaryGreen))
                        .scaleEffect(1.3)
                    Text("Cargando viajes...")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            } else if bookings.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 18) {
                        ForEach(bookings) { booking in
                            TripCardWithActions(
                                booking: booking,
                                isFavorite: favoriteIds.contains(booking.id),
                                onFavoriteToggle: {
                                    toggleFavorite(booking)
                                }
                            )
                            .environmentObject(viewModel)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Mis Viajes")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onAppear {
            loadBookings()
            loadFavorites()
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .foregroundColor(.clear)
                    .background(primaryGradient.opacity(0.2))
                    .frame(width: 140, height: 140)
                    .clipShape(Circle())
                
                Image(systemName: "bus.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
            }
            
            VStack(spacing: 10) {
                Text("No tienes viajes reservados")
                    .font(.title2.bold())
                    .foregroundColor(isDarkMode ? .white : .black)
                
                Text("Comienza a explorar y reserva\ntu próxima aventura")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
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
    
    private func loadFavorites() {
        guard let userId = viewModel.userSession?.uid else { return }
        
        Firestore.firestore()
            .collection("favorites")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { snapshot, _ in
                if let docs = snapshot?.documents {
                    DispatchQueue.main.async {
                        self.favoriteIds = Set(docs.compactMap { $0.data()["bookingId"] as? String })
                    }
                }
            }
    }
    
    private func toggleFavorite(_ booking: BookingData) {
        guard let userId = viewModel.userSession?.uid else { return }
        
        if favoriteIds.contains(booking.id) {
            // Remove from favorites
            Firestore.firestore()
                .collection("favorites")
                .whereField("userId", isEqualTo: userId)
                .whereField("bookingId", isEqualTo: booking.id)
                .getDocuments { snapshot, _ in
                    if let document = snapshot?.documents.first {
                        document.reference.delete()
                    }
                    DispatchQueue.main.async {
                        self.favoriteIds.remove(booking.id)
                    }
                }
        } else {
            // Add to favorites
            let favoriteData: [String: Any] = [
                "userId": userId,
                "bookingId": booking.id,
                "origin": booking.origin,
                "destination": booking.destination,
                "date": Timestamp(date: booking.date),
                "time": booking.time,
                "seatNumber": booking.seatNumber,
                "price": booking.price,
                "isTouristPlace": booking.isTouristPlace,
                "numberOfPeople": booking.numberOfPeople ?? 1,
                "addedAt": Timestamp(date: Date())
            ]
            
            Firestore.firestore()
                .collection("favorites")
                .addDocument(data: favoriteData) { error in
                    guard error == nil else { return }
                    DispatchQueue.main.async {
                        self.favoriteIds.insert(booking.id)
                    }
                }
        }
    }
}

struct TripCardWithActions: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    let booking: BookingData
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void
    
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var showShareSheet = false
    @State private var hasRating = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header con botón de favorito
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .foregroundColor(booking.status == "paid" ? .green : .orange)
                        .frame(width: 9, height: 9)
                    Text(booking.status == "paid" ? "Pagado" : "Pendiente")
                        .font(.caption.bold())
                        .foregroundColor(booking.status == "paid" ? .green : .orange)
                }
                
                Spacer()
                
                Button(action: {
                    onFavoriteToggle()
                }) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 20))
                        .foregroundColor(isFavorite ? .red : .gray)
                        .scaleEffect(isFavorite ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.2))
                        .padding(8)
                        .background(
                            Circle()
                                .foregroundColor(isDarkMode ? Color.gray.opacity(0.3) : Color.white)
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        )
                }
            }
            .padding()
            .background(isDarkMode ? Color.gray.opacity(0.1) : Color.gray.opacity(0.05))
            
            VStack(spacing: 18) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(booking.origin)
                            .font(.title3.bold())
                            .foregroundColor(isDarkMode ? .white : .black)
                        Text(booking.time)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Image(systemName: booking.isTouristPlace ? "camera.viewfinder" : "arrow.right")
                        .font(.title2)
                        .foregroundColor(.blue)
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(booking.destination)
                            .font(.title3.bold())
                            .foregroundColor(isDarkMode ? .white : .black)
                        Text(booking.dateString)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Divider()
                
                HStack {
                    if booking.isTouristPlace {
                        HStack(spacing: 6) {
                            Image(systemName: "person.3.fill")
                                .foregroundColor(.blue)
                            Text("\(booking.numberOfPeople ?? 1) persona(s)")
                                .font(.subheadline.bold())
                                .foregroundColor(.blue)
                        }
                    } else {
                        HStack(spacing: 6) {
                            Image(systemName: "airline.seat.recline.normal")
                                .foregroundColor(.blue)
                            Text("Asiento \(booking.seatNumber)")
                                .font(.subheadline.bold())
                                .foregroundColor(.blue)
                        }
                    }
                    Spacer()
                    if booking.isTouristPlace {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(Color(red: 1, green: 0.85, blue: 0.0))
                        Text("Tour")
                            .font(.caption.bold())
                            .foregroundColor(Color(red: 1, green: 0.85, blue: 0.0))
                    }
                }
                
                HStack {
                    Text("Total: S/ \(String(format: "%.2f", booking.price))")
                        .font(.headline)
                        .foregroundColor(.blue)
                    Spacer()
                }
            }
            .padding()
            
            Divider()
            
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    NavigationLink(destination: TicketDetailView(bookingId: booking.id)
                        .environmentObject(viewModel)) {
                        HStack(spacing: 6) {
                            Image(systemName: "ticket.fill")
                            Text("Ver Boleto")
                        }
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(primaryGradient)
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        showShareSheet = true
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "square.and.arrow.up")
                            Text("Compartir")
                        }
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(LinearGradient(
                            gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .cornerRadius(12)
                    }
                    .sheet(isPresented: $showShareSheet) {
                        ShareSheet(activityItems: [generateTicketImage()])
                    }
                }
                
                if booking.status == "pending" {
                    if booking.paymentMethod == "cash" {
                        Button(action: {}) {
                            HStack(spacing: 6) {
                                Image(systemName: "building.2.fill")
                                Text("Pagar en Agencia")
                            }
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
                            HStack(spacing: 6) {
                                Image(systemName: "creditcard.fill")
                                Text("Pagar Ahora")
                            }
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.green)
                            .cornerRadius(12)
                        }
                    }
                } else if booking.status == "paid" {
                    if hasRating {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                            Text("Viaje Terminado")
                                .font(.headline.bold())
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.gray)
                        .cornerRadius(12)
                    } else {
                        NavigationLink(destination: TripSimulationView(booking: booking)) {
                            HStack(spacing: 8) {
                                Image(systemName: "location.fill")
                                    .font(.title3)
                                Text("Iniciar Viaje")
                                    .font(.headline.bold())
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.0, green: 0.7, blue: 0.3),
                                        Color(red: 0.0, green: 0.5, blue: 0.8)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                            .shadow(color: Color.green.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 12)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(isDarkMode ? Color.gray.opacity(0.2) : Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(primaryGradient, lineWidth: 2)
        )
        .shadow(color: isDarkMode ? .clear : .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .onAppear {
            checkForRating()
        }
    }
    
    private func checkForRating() {
        Firestore.firestore()
            .collection("ratings")
            .whereField("bookingId", isEqualTo: booking.id)
            .getDocuments { snapshot, _ in
                DispatchQueue.main.async {
                    self.hasRating = (snapshot?.documents.count ?? 0) > 0
                }
            }
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
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 16) {
                ticketRow("Origen", booking.origin)
                ticketRow("Destino", booking.destination)
                ticketRow("Fecha", booking.dateString)
                ticketRow("Hora", booking.time)
                
                if booking.isTouristPlace {
                    ticketRow("Personas", "\(booking.numberOfPeople ?? 1)")
                    if let type = booking.travelType {
                        ticketRow("Tipo", type)
                    }
                } else {
                    ticketRow("Asiento", "\(booking.seatNumber)")
                }
                
                ticketRow("Total", "S/ \(String(format: "%.2f", booking.price))")
                    .foregroundColor(.blue)
            }
            .font(.title3)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(30)
            .background(Color.white)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.blue, lineWidth: 4)
            )
        }
        .padding(30)
    }
    
    private func ticketRow(_ title: String, _ value: String) -> some View {
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
