import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct BusSelectionView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    let origin: String
    let destination: String
    let date: Date
    let time: String
    
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedSeat: Int?
    @State private var bookedSeats: [Int] = []
    @State private var isLoading = true
    @State private var isCreatingBooking = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    private let totalSeats = 16
    private let seatsPerRow = 4
    private let pricePerSeat: Double = 15.0
    
    var body: some View {
        ZStack {
            (isDarkMode ? Color.black : Color.white)
                .edgesIgnoringSafeArea(.all)
            
            if isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.primaryGreen))
                        .scaleEffect(1.3)
                    Text("Cargando asientos...")
                        .foregroundColor(.gray)
                }
            } else {
                ScrollView {
                    VStack(spacing: 25) {
                        tripInfoCard
                        legendSection
                        seatsSection
                        if let seat = selectedSeat {
                            selectedSeatInfo(seat: seat)
                        }
                        Spacer(minLength: 50)
                    }
                    .padding(.top, 20)
                }
            }
            
            if isCreatingBooking {
                ZStack {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 15) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        Text("Creando reserva...")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                }
            }
        }
        .navigationTitle("Seleccionar Asiento")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack(spacing: 5) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                    Text("Reserva de Pasaje")
                        .font(.system(size: 17))
                }
                .foregroundColor(.blue)
            }
        )
        .onAppear { loadBookedSeats() }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Reserva Creada"),
                message: Text(alertMessage),
                primaryButton: .default(Text("Ir a Mis Viajes")) {
                    if let tabBar = UIApplication.shared.windows.first?.rootViewController as? UITabBarController {
                        tabBar.selectedIndex = 2
                    }
                    presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel(Text("Continuar"))
            )
        }
    }
    
    @ViewBuilder
    private var tripInfoCard: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(origin)
                        .font(.title3.bold())
                        .foregroundColor(isDarkMode ? .white : .black)
                    Text(time)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                Image(systemName: "arrow.right")
                    .foregroundColor(.blue)
                    .font(.title2)
                Spacer()
                VStack(alignment: .trailing, spacing: 5) {
                    Text(destination)
                        .font(.title3.bold())
                        .foregroundColor(isDarkMode ? .white : .black)
                    Text(formatDate(date))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(primaryGradient, lineWidth: 1.5)
            )
        }
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private var legendSection: some View {
        HStack(spacing: 30) {
            LegendItem(color: Color.gray.opacity(0.2), text: "Disponible", isDarkMode: isDarkMode)
            LegendItem(color: Color.red.opacity(0.4), text: "Ocupado", isDarkMode: isDarkMode)
            LegendItemGradient(text: "Seleccionado", isDarkMode: isDarkMode)
        }
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private var seatsSection: some View {
        VStack(spacing: 20) {
            HStack(spacing: 8) {
                Image(systemName: "airline.seat.recline.normal")
                    .foregroundColor(.blue)
                Text("Selecciona tu asiento")
                    .foregroundColor(isDarkMode ? .white : .black)
            }
            .font(.title3.bold())
            
            Text("Precio por asiento: S/ \(String(format: "%.2f", pricePerSeat))")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack {
                Spacer()
                VStack(spacing: 5) {
                    Image(systemName: "steeringwheel")
                        .font(.system(size: 32))
                        .foregroundColor(.blue)
                    Text("Conductor")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 30)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: seatsPerRow), spacing: 20) {
                ForEach(1...totalSeats, id: \.self) { seatNumber in
                    SeatButtonGradient(
                        seatNumber: seatNumber,
                        isBooked: bookedSeats.contains(seatNumber),
                        isSelected: selectedSeat == seatNumber,
                        isDarkMode: isDarkMode
                    ) {
                        if !bookedSeats.contains(seatNumber) {
                            selectedSeat = seatNumber
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func selectedSeatInfo(seat: Int) -> some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.green)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Asiento \(seat)")
                            .font(.title2.bold())
                            .foregroundColor(isDarkMode ? .white : .black)
                        Text("Total: S/ \(String(format: "%.2f", pricePerSeat))")
                            .font(.title3.bold())
                            .foregroundColor(.green)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(primaryGradient, lineWidth: 2)
            )
            .padding(.horizontal, 20)
            
            Button(action: {
                createBookingAndNavigate()
            }) {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.title3)
                    Text("CONFIRMAR RESERVA")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 55)
                .background(primaryGradient)
                .cornerRadius(16)
            }
            .disabled(isCreatingBooking)
            .padding(.horizontal, 20)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "EEE d MMM"
        f.locale = Locale(identifier: "es_PE")
        return f.string(from: date).capitalized
    }
    
    private func loadBookedSeats() {
        isLoading = true
        
        let df = DateFormatter()
        df.dateStyle = .medium
        df.locale = Locale(identifier: "en_US")
        let dateString = df.string(from: date)
        
        Firestore.firestore()
            .collection("bookings")
            .whereField("origin", isEqualTo: origin)
            .whereField("destination", isEqualTo: destination)
            .whereField("dateString", isEqualTo: dateString)
            .whereField("time", isEqualTo: time)
            .whereField("status", in: ["pending", "paid"])
            .getDocuments { snapshot, _ in
                isLoading = false
                
                if let docs = snapshot?.documents {
                    bookedSeats = docs.compactMap { $0.data()["seatNumber"] as? Int }
                }
            }
    }
    
    private func createBookingAndNavigate() {
        guard let userId = viewModel.userSession?.uid, let seat = selectedSeat else { return }
        
        isCreatingBooking = true
        
        let df = DateFormatter()
        df.dateStyle = .medium
        df.locale = Locale(identifier: "en_US")
        let dateString = df.string(from: date)
        
        let niceDate = DateFormatter()
        niceDate.dateFormat = "EEEE d 'de' MMMM"
        niceDate.locale = Locale(identifier: "es_PE")
        let fechaBonita = niceDate.string(from: date).capitalized
        
        let data: [String: Any] = [
            "userId": userId,
            "origin": origin,
            "destination": destination,
            "date": Timestamp(date: date),
            "dateString": dateString,
            "time": time,
            "seatNumber": seat,
            "price": pricePerSeat,
            "status": "pending",
            "paymentMethod": "none",
            "createdAt": Timestamp(),
            "placeType": "regular"
        ]
        
        Firestore.firestore().collection("bookings").addDocument(data: data) { error in
            DispatchQueue.main.async {
                isCreatingBooking = false
                
                if let error = error {
                    alertMessage = "Error: \(error.localizedDescription)"
                } else {
                    alertMessage = """
                    ¡Reserva creada con éxito!
                    
                    Origen: \(origin)
                    Destino: \(destination)
                    Fecha: \(fechaBonita)
                    Hora: \(time)
                    Asiento: \(seat)
                    Total: S/ \(String(format: "%.2f", pricePerSeat))
                    
                    Recuerda completar el pago en Mis Viajes
                    """
                }
                showAlert = true
            }
        }
    }
}

// MARK: - Componentes reutilizados

struct LegendItem: View {
    let color: Color
    let text: String
    let isDarkMode: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .foregroundColor(color)
                .frame(width: 20, height: 20)
            Text(text)
                .font(.caption)
                .foregroundColor(isDarkMode ? .white : .black)
        }
    }
}

struct LegendItemGradient: View {
    let text: String
    let isDarkMode: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .foregroundColor(.clear)
                .background(primaryGradient)
                .frame(width: 20, height: 20)
                .clipShape(Circle())
            Text(text)
                .font(.caption)
                .foregroundColor(isDarkMode ? .white : .black)
        }
    }
}

struct SeatButtonGradient: View {
    let seatNumber: Int
    let isBooked: Bool
    let isSelected: Bool
    let isDarkMode: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: "airline.seat.recline.normal")
                    .font(.title2)
                Text("\(seatNumber)")
                    .font(.caption2.bold())
            }
            .frame(width: 65, height: 65)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(backgroundFill)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(primaryGradient, lineWidth: isSelected ? 2.5 : 0)
                    )
            )
            .foregroundColor(isSelected ? Color(red: 0.0, green: 0.78, blue: 0.58) : (isBooked ? .red : (isDarkMode ? .white : .black)))
        }
        .disabled(isBooked)
    }
    
    private var backgroundFill: Color {
        if isBooked { return Color.red.opacity(0.15) }
        if isSelected { return Color(red: 0.0, green: 0.78, blue: 0.58).opacity(0.1) }
        return isDarkMode ? Color.gray.opacity(0.3) : Color.gray.opacity(0.1)
    }
}
