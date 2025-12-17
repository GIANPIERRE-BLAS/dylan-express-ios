import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct TouristPlaceView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    let place: TouristPlace
    let origin: String
    @State private var travelType: TravelType = .solo
    @State private var numberOfPeople = 2
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var selectedDate = Date()
    @State private var selectedTime = "09:00 AM"
    @State private var selectedSeats: [Int] = []
    
    enum TravelType: String, CaseIterable {
        case solo = "Solo"
        case group = "Grupo"
    }
    
    let availableTimes = [
        "06:00 AM", "08:00 AM", "10:00 AM", "12:00 PM",
        "02:00 PM", "04:00 PM", "06:00 PM", "08:00 PM"
    ]
    
    private let basePrice: Double = 15.0
    
    private var discountPercentage: Double {
        let discountText = place.discount.replacingOccurrences(of: "%", with: "").replacingOccurrences(of: " OFF", with: "").trimmingCharacters(in: .whitespaces)
        return Double(discountText) ?? 0
    }
    
    private var pricePerPerson: Double {
        basePrice * (1 - discountPercentage / 100)
    }
    
    private var totalPrice: Double {
        switch travelType {
        case .solo:
            return pricePerPerson
        case .group:
            return pricePerPerson * Double(numberOfPeople)
        }
    }
    
    var body: some View {
        ZStack {
            (isDarkMode ? Color.black : Color.white)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 25) {
                    ZStack(alignment: .topTrailing) {
                        AsyncImage(url: URL(string: place.imageUrl)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: UIScreen.main.bounds.width - 40, height: 220)
                                    .clipped()
                            case .failure(_):
                                ZStack {
                                    Color.gray.opacity(0.2)
                                    Image(systemName: "photo")
                                        .font(.largeTitle)
                                        .foregroundColor(.gray)
                                }
                                .frame(width: UIScreen.main.bounds.width - 40, height: 220)
                            case .empty:
                                ZStack {
                                    Color.gray.opacity(0.2)
                                    ProgressView()
                                }
                                .frame(width: UIScreen.main.bounds.width - 40, height: 220)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(width: UIScreen.main.bounds.width - 40, height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        
                        Text(place.discount)
                            .font(.title3.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Capsule().foregroundColor(Color.red))
                            .padding(26)
                    }
                    
                    VStack(spacing: 25) {
                        Group {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(place.name)
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(isDarkMode ? .white : .black)
                                
                                HStack(spacing: 8) {
                                    Image(systemName: "mappin.and.ellipse")
                                        .foregroundColor(.blue)
                                    Text("La Libertad, Perú")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
                                HStack(spacing: 8) {
                                    Image(systemName: "location.fill")
                                        .foregroundColor(.blue)
                                    Text("Salida desde: \(origin)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
                                Text(getPlaceDescription())
                                    .font(.body)
                                    .foregroundColor(.gray)
                                    .lineSpacing(6)
                                    .padding(.top, 8)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Divider()
                            
                            priceSection
                            
                            Divider()
                            
                            dateAndTimeSection
                            
                            Divider()
                            
                            travelTypeSection
                        }
                        
                        Group {
                            if travelType == .group {
                                numberOfPeopleSection
                            }
                            
                            Divider()
                            
                            seatSelectionSection
                            
                            Divider()
                            
                            totalSection
                        }
                    }
                    .padding(.horizontal, 25)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationTitle("Viaje Turístico")
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
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Reserva Creada"),
                message: Text(alertMessage),
                primaryButton: .default(Text("Ir a Mis Viajes")) {
                    presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel(Text("Continuar"))
            )
        }
    }
    
    private func addToMyTrips() {
        guard let userId = viewModel.userSession?.uid else {
            alertMessage = "Debes iniciar sesión para agregar viajes"
            showAlert = true
            return
        }
        
        if selectedSeats.isEmpty {
            alertMessage = "Por favor selecciona tus asientos"
            showAlert = true
            return
        }
        
        let bookingData: [String: Any] = [
            "userId": userId,
            "origin": origin,
            "destination": place.name,
            "date": Timestamp(date: selectedDate),
            "time": selectedTime,
            "seatNumber": selectedSeats.first ?? 0,
            "selectedSeats": selectedSeats,
            "price": totalPrice,
            "status": "pending",
            "paymentMethod": "pending",
            "createdAt": Timestamp(date: Date()),
            "travelType": travelType.rawValue,
            "numberOfPeople": travelType == .group ? numberOfPeople : 1,
            "placeType": "tourist"
        ]
        
        Firestore.firestore()
            .collection("bookings")
            .addDocument(data: bookingData) { error in
                if let error = error {
                    alertMessage = "Error al crear la reserva: \(error.localizedDescription)"
                } else {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .medium
                    let dateString = dateFormatter.string(from: selectedDate)
                    alertMessage = "¡Reserva creada para \(place.name)!\n\n Origen: \(origin)\n Fecha: \(dateString)\n Hora: \(selectedTime)\n Asientos: \(selectedSeats.map { String($0) }.joined(separator: ", "))\n Total: S/ \(String(format: "%.2f", totalPrice))\n\n Recuerda completar el pago en Mis Viajes"
                }
                showAlert = true
            }
    }
    
    private func getPlaceDescription() -> String {
        switch place.name {
        case "Chan Chan":
            return "La ciudad de barro más grande de América precolombina. Declarada Patrimonio de la Humanidad por la UNESCO, esta antigua capital del reino Chimú te transportará a través de siglos de historia."
        case "Huacas del Sol y Luna":
            return "Impresionantes pirámides construidas por la civilización Moche. Descubre los increíbles murales policromados y aprende sobre una de las culturas más fascinantes del Perú antiguo."
        case "Plaza de Armas":
            return "El corazón colonial de Trujillo, rodeada de hermosas casonas republicanas y la majestuosa Catedral. Un lugar perfecto para disfrutar de la arquitectura y la vida trujillana."
        case "Huamachuco (Plaza de Armas)":
            return "Encantadora plaza en el corazón de los Andes liberteños. Disfruta del clima fresco y la hospitalidad de este pueblo histórico que fue clave en la independencia del Perú."
        case "Marcahuamachuco (Complejo Arqueológico)":
            return "Impresionante complejo arqueológico pre-inca ubicado a 3,700 metros sobre el nivel del mar. Sus enormes murallas circulares te dejarán sin aliento."
        case "Laguna de Sausacocha":
            return "Hermoso espejo de agua en las alturas de La Libertad. Ideal para los amantes de la naturaleza, el trekking y la fotografía de paisajes andinos."
        case "Ruinas de Wiracochapampa":
            return "Sitio arqueológico de la cultura Wari, con estructuras rectangulares únicas. Un lugar místico que revela los secretos de una civilización preincaica fascinante."
        case "Santiago de Chuco (Tierra de César Vallejo)":
            return "Pueblo natal del célebre poeta César Vallejo. Recorre sus calles empedradas y visita la casa donde nació uno de los más grandes poetas de América Latina."
        default:
            return "Descubre este maravilloso lugar turístico en La Libertad. Una experiencia única que combina historia, cultura y naturaleza en el corazón del Perú."
        }
    }
    
    private var priceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "tag.fill")
                    .foregroundColor(.blue)
                Text("Información de Precios")
                    .font(.headline)
                    .foregroundColor(isDarkMode ? .white : .black)
            }
            
            VStack(spacing: 10) {
                HStack {
                    Text("Precio original:")
                        .foregroundColor(.gray)
                    Spacer()
                    Text("S/ \(String(format: "%.2f", basePrice))")
                        .strikethrough()
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text("Descuento aplicado:")
                        .foregroundColor(.gray)
                    Spacer()
                    Text("-\(String(format: "%.0f", discountPercentage))%")
                        .foregroundColor(.red)
                        .bold()
                }
                
                HStack {
                    Text("Precio por persona:")
                        .font(.subheadline.bold())
                        .foregroundColor(isDarkMode ? .white : .black)
                    Spacer()
                    Text("S/ \(String(format: "%.2f", pricePerPerson))")
                        .font(.title3.bold())
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .foregroundColor(isDarkMode ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
            )
        }
    }
    
    private var dateAndTimeSection: some View {
        HStack(spacing: 15) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                    Text("Fecha del Tour")
                        .font(.subheadline.bold())
                        .foregroundColor(.gray)
                }
                
                DatePicker(
                    "",
                    selection: $selectedDate,
                    in: Date()...,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.compact)
                .labelsHidden()
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(primaryGradient, lineWidth: 1.7)
                )
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.blue)
                    Text("Hora de salida")
                        .font(.subheadline.bold())
                        .foregroundColor(.gray)
                }
                
                Menu {
                    ForEach(availableTimes, id: \.self) { time in
                        Button(time) {
                            selectedTime = time
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "timer")
                            .foregroundColor(.blue)
                            .font(.title3)
                        
                        Text(selectedTime)
                            .foregroundColor(isDarkMode ? .white : .black)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .foregroundColor(.blue)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(primaryGradient, lineWidth: 1.7)
                    )
                }
            }
        }
    }
    
    private var travelTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "person.2.fill")
                    .foregroundColor(.blue)
                Text("Tipo de Viaje")
                    .font(.headline)
                    .foregroundColor(isDarkMode ? .white : .black)
            }
            
            HStack(spacing: 12) {
                ForEach(TravelType.allCases, id: \.self) { type in
                    Button(action: {
                        travelType = type
                        selectedSeats = []
                    }) {
                        HStack {
                            Image(systemName: travelType == type ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(.blue)
                            Text(type.rawValue)
                                .foregroundColor(isDarkMode ? .white : .black)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(primaryGradient, lineWidth: travelType == type ? 2 : 1)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .foregroundColor(travelType == type ? Color.gray.opacity(0.2) : Color.clear)
                                )
                        )
                    }
                }
            }
        }
    }
    
    private var numberOfPeopleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "person.3.fill")
                    .foregroundColor(.blue)
                Text("Número de Personas")
                    .font(.subheadline.bold())
                    .foregroundColor(.gray)
            }
            
            HStack {
                Button(action: {
                    if numberOfPeople > 2 {
                        numberOfPeople -= 1
                        if selectedSeats.count > numberOfPeople {
                            selectedSeats = Array(selectedSeats.prefix(numberOfPeople))
                        }
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text("\(numberOfPeople)")
                    .font(.title2.bold())
                    .foregroundColor(isDarkMode ? .white : .black)
                
                Spacer()
                
                Button(action: {
                    if numberOfPeople < 10 {
                        numberOfPeople += 1
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(primaryGradient, lineWidth: 1.7)
            )
        }
    }
    
    private var seatSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "airline.seat.recline.normal")
                    .foregroundColor(.blue)
                Text("Selección de Asientos")
                    .font(.headline)
                    .foregroundColor(isDarkMode ? .white : .black)
            }
            
            if selectedSeats.isEmpty {
                NavigationLink(destination: TouristSeatSelectionView(
                    selectedSeats: $selectedSeats,
                    numberOfSeats: travelType == .solo ? 1 : numberOfPeople,
                    destination: place.name,
                    selectedDate: selectedDate
                )) {
                    HStack {
                        Image(systemName: "hand.tap.fill")
                            .foregroundColor(.blue)
                        Text("Seleccionar Asientos")
                            .foregroundColor(isDarkMode ? .white : .black)
                        Spacer()
                        Text("(\(travelType == .solo ? "1" : "\(numberOfPeople)") asiento\(travelType == .solo || numberOfPeople == 1 ? "" : "s"))")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Image(systemName: "chevron.right")
                            .foregroundColor(.blue)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(primaryGradient, lineWidth: 1.7)
                    )
                }
            } else {
                VStack(spacing: 10) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Asientos seleccionados:")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text(selectedSeats.map { String($0) }.joined(separator: ", "))
                                .font(.headline)
                                .foregroundColor(.green)
                        }
                        Spacer()
                        NavigationLink(destination: TouristSeatSelectionView(
                            selectedSeats: $selectedSeats,
                            numberOfSeats: travelType == .solo ? 1 : numberOfPeople,
                            destination: place.name,
                            selectedDate: selectedDate
                        )) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.title3)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .foregroundColor(isDarkMode ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
                    )
                }
            }
        }
    }
    
    private var totalSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total a Pagar")
                        .font(.headline)
                        .foregroundColor(isDarkMode ? .white : .black)
                    if travelType == .group {
                        Text("\(numberOfPeople) personas × S/ \(String(format: "%.2f", pricePerPerson))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
                Text("S/ \(String(format: "%.2f", totalPrice))")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.green)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(primaryGradient, lineWidth: 2)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .foregroundColor(isDarkMode ? Color.gray.opacity(0.1) : Color.white)
                    )
            )
            
            Button(action: {
                addToMyTrips()
            }) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.headline)
                    Text("CONFIRMAR RESERVA")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    Group {
                        if selectedSeats.isEmpty {
                            Color.gray
                        } else {
                            primaryGradient
                        }
                    }
                )
                .cornerRadius(16)
            }
            .disabled(selectedSeats.isEmpty)
        }
    }
}

struct TouristSeatSelectionView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @Binding var selectedSeats: [Int]
    let numberOfSeats: Int
    let destination: String
    let selectedDate: Date
    @Environment(\.presentationMode) var presentationMode
    @State private var tempSelectedSeats: [Int] = []
    @State private var occupiedSeats: [Int] = []
    @State private var isLoading = true
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)
    let totalSeats = 16
    
    var body: some View {
        ZStack {
            (isDarkMode ? Color.black : Color.white)
                .edgesIgnoringSafeArea(.all)
            
            if isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(1.3)
                    Text("Cargando asientos...")
                        .foregroundColor(.gray)
                }
            } else {
                ScrollView {
                    VStack(spacing: 25) {
                        legendSection
                        
                        Text("Selecciona \(numberOfSeats) asiento\(numberOfSeats == 1 ? "" : "s")")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        driverSection
                        
                        seatsGrid
                        
                        if tempSelectedSeats.count == numberOfSeats {
                            confirmButton
                        }
                        
                        Spacer(minLength: 30)
                    }
                    .padding(.top, 20)
                }
            }
        }
        .navigationTitle("Seleccionar Asientos")
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
        .onAppear {
            tempSelectedSeats = selectedSeats
            loadOccupiedSeats()
        }
    }
    
    private var legendSection: some View {
        HStack(spacing: 20) {
            HStack(spacing: 8) {
                Circle()
                    .foregroundColor(Color.gray.opacity(0.2))
                    .frame(width: 20, height: 20)
                Text("Disponible")
                    .font(.caption)
                    .foregroundColor(isDarkMode ? .white : .black)
            }
            
            HStack(spacing: 8) {
                Circle()
                    .foregroundColor(Color(red: 1, green: 0.85, blue: 0.0))
                    .frame(width: 20, height: 20)
                Text("Seleccionado")
                    .font(.caption)
                    .foregroundColor(isDarkMode ? .white : .black)
            }
            
            HStack(spacing: 8) {
                Circle()
                    .foregroundColor(Color.red.opacity(0.3))
                    .frame(width: 20, height: 20)
                Text("Ocupado")
                    .font(.caption)
                    .foregroundColor(isDarkMode ? .white : .black)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var driverSection: some View {
        HStack {
            Spacer()
            VStack(spacing: 4) {
                Image(systemName: "steeringwheel")
                    .font(.title)
                    .foregroundColor(.blue)
                Text("Conductor")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(isDarkMode ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
        )
        .padding(.horizontal, 20)
    }
    
    private var seatsGrid: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(1...totalSeats, id: \.self) { seatNumber in
                SeatButton(
                    seatNumber: seatNumber,
                    isSelected: tempSelectedSeats.contains(seatNumber),
                    isOccupied: occupiedSeats.contains(seatNumber),
                    isDarkMode: isDarkMode,
                    action: {
                        toggleSeat(seatNumber)
                    }
                )
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var confirmButton: some View {
        Button(action: {
            selectedSeats = tempSelectedSeats.sorted()
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text("CONFIRMAR ASIENTOS")
                    .font(.headline)
                Text("(\(tempSelectedSeats.count))")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(primaryGradient)
            .cornerRadius(16)
        }
        .padding(.horizontal, 20)
    }
    
    private func loadOccupiedSeats() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        Firestore.firestore()
            .collection("bookings")
            .whereField("destination", isEqualTo: destination)
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("date", isLessThan: Timestamp(date: endOfDay))
            .whereField("status", in: ["pending", "paid"])
            .getDocuments { snapshot, error in
                isLoading = false
                
                if let error = error {
                    print("Error loading occupied seats: \(error)")
                    return
                }
                
                var occupied: [Int] = []
                snapshot?.documents.forEach { doc in
                    if let seats = doc.data()["selectedSeats"] as? [Int] {
                        occupied.append(contentsOf: seats)
                    }
                }
                
                occupiedSeats = Array(Set(occupied))
            }
    }
    
    private func toggleSeat(_ seatNumber: Int) {
        if occupiedSeats.contains(seatNumber) { return }
        
        if tempSelectedSeats.contains(seatNumber) {
            tempSelectedSeats.removeAll { $0 == seatNumber }
        } else {
            if tempSelectedSeats.count < numberOfSeats {
                tempSelectedSeats.append(seatNumber)
            }
        }
    }
}

struct SeatButton: View {
    let seatNumber: Int
    let isSelected: Bool
    let isOccupied: Bool
    let isDarkMode: Bool
    let action: () -> Void
    
    var backgroundColor: Color {
        if isOccupied {
            return Color.red.opacity(0.2)
        } else if isSelected {
            return Color(red: 1, green: 0.85, blue: 0.0)
        } else {
            return isDarkMode ? Color.gray.opacity(0.3) : Color.gray.opacity(0.15)
        }
    }
    
    var textColor: Color {
        if isOccupied {
            return Color.red.opacity(0.7)
        } else if isSelected {
            return .white
        } else {
            return isDarkMode ? .white : .black
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: "airline.seat.recline.normal")
                    .font(.title2)
                Text("\(seatNumber)")
                    .font(.caption2.bold())
            }
            .foregroundColor(textColor)
            .frame(height: 70)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isOccupied ? Color.red.opacity(0.5) :
                        isSelected ? Color.clear :
                        Color.gray.opacity(0.3),
                        lineWidth: 1
                    )
            )
        }
        .disabled(isOccupied)
    }
}
