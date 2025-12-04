import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct TouristPlaceDetailView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    let place: TouristPlace
    
    @State private var selectedOption: TravelOption = .solo
    @State private var numberOfPeople = 1
    @State private var selectedDate = Date()
    @State private var showSuccessAlert = false
    @State private var isBooking = false
    
    enum TravelOption: String, CaseIterable {
        case solo = "Solo"
        case pareja = "En Pareja"
        case familia = "Familia"
        case grupo = "Grupo"
        
        var icon: String {
            switch self {
            case .solo: return "person.fill"
            case .pareja: return "person.2.fill"
            case .familia: return "figure.2.and.child.holdinghands"
            case .grupo: return "person.3.fill"
            }
        }
        
        var maxPeople: Int {
            switch self {
            case .solo: return 1
            case .pareja: return 2
            case .familia: return 6
            case .grupo: return 15
            }
        }
    }
    
    var basePrice: Double { 50.0 }
    
    var discountPercentage: Double {
        Double(place.discount.replacingOccurrences(of: "% OFF", with: "").trimmingCharacters(in: .whitespaces)) ?? 0
    }
    
    var priceAfterDiscount: Double {
        basePrice * (1 - discountPercentage / 100)
    }
    
    var totalPrice: Double {
        priceAfterDiscount * Double(numberOfPeople)
    }
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 0) {
                    heroImage
                    
                    VStack(spacing: 25) {
                        headerInfo
                        Divider()
                        descriptionSection
                        Divider()
                        travelOptionsSection
                        
                        if selectedOption != .solo {
                            peopleCounterSection
                        }
                        
                        Divider()
                        dateSelectionSection
                        Divider()
                        priceBreakdown
                        
                        Button {
                            bookTouristPlace()
                        } label: {
                            HStack {
                                if isBooking {
                                    ProgressView()
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("AGREGAR A MIS VIAJES")
                                }
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 0.0, green: 0.78, blue: 0.58))
                            .cornerRadius(16)
                        }
                        .disabled(isBooking)

                    }
                    .padding(.horizontal, 25)
                    .padding(.vertical, 20)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showSuccessAlert) {
            Alert(
                title: Text("Reserva Exitosa!"),
                message: Text("Tu visita turística ha sido agregada a Mis Viajes. Puedes completar el pago desde allí."),
                primaryButton: .default(Text("Ver Mis Viajes"), action: {
                    dismiss()
                }),
                secondaryButton: .cancel(Text("Continuar Explorando"), action: {
                    dismiss()
                })
            )
        }
    }
    
    var heroImage: some View {
        ZStack(alignment: .topTrailing) {
            AsyncImage(url: URL(string: place.imageUrl)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width, height: 280)
                        .clipped()
                case .failure:
                    Color.gray.opacity(0.3)
                        .overlay(Image(systemName: "photo.fill").font(.largeTitle).foregroundColor(.gray))
                        .frame(width: UIScreen.main.bounds.width, height: 280)
                case .empty:
                    Color.gray.opacity(0.3)
                        .overlay(ProgressView().tint(Color(red: 0.0, green: 0.78, blue: 0.58)))
                        .frame(width: UIScreen.main.bounds.width, height: 280)
                @unknown default:
                    EmptyView()
                }
            }
            
            Text(place.discount)
                .font(.title3.bold())
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Capsule().fill(Color.red).shadow(radius: 5))
                .padding(20)
        }
        .frame(height: 280)
    }
    
    var headerInfo: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(place.name)
                .font(.title.bold())
                .foregroundColor(.black)
            
            HStack(spacing: 8) {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(Color(red: 0.0, green: 0.78, blue: 0.58))
                Text("La Libertad, Perú")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                HStack(spacing: 4) {
                    ForEach(0..<5) { index in
                        Image(systemName: index < 4 ? "star.fill" : "star.leadinghalf.filled")
                            .foregroundColor(Color(red: 1, green: 0.85, blue: 0.0))
                            .font(.caption)
                    }
                    Text("4.5")
                        .font(.caption.bold())
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(Color(red: 0.0, green: 0.78, blue: 0.58))
                Text("Descripción")
                    .font(.headline)
            }
            Text(getDescription(for: place.name))
                .font(.body)
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
    }
    
    var travelOptionsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "person.2.fill")
                    .foregroundColor(Color(red: 0.0, green: 0.78, blue: 0.58))
                Text("¿Con quién viajas?")
                    .font(.headline)
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(TravelOption.allCases, id: \.self) { option in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            selectedOption = option
                            numberOfPeople = option == .solo ? 1 : (option == .pareja ? 2 : numberOfPeople)
                        }
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: option.icon)
                                .font(.title2)
                                .foregroundColor(selectedOption == option ? Color(red: 0.0, green: 0.78, blue: 0.58) : .gray)
                            Text(option.rawValue)
                                .font(.subheadline.bold())
                                .foregroundColor(selectedOption == option ? .black : .gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(selectedOption == option ? Color.gray.opacity(0.1) : Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(selectedOption == option ? Color(red: 0.0, green: 0.78, blue: 0.58) : Color.gray.opacity(0.3), lineWidth: selectedOption == option ? 2.5 : 1)
                                )
                        )
                    }
                }
            }
        }
    }
    
    var peopleCounterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "number.circle.fill")
                    .foregroundColor(Color(red: 0.0, green: 0.78, blue: 0.58))
                Text("Número de personas")
                    .font(.headline)
            }
            
            HStack {
                Button {
                    if numberOfPeople > (selectedOption == .pareja ? 2 : 1) {
                        withAnimation(.spring(response: 0.3)) {
                            numberOfPeople -= 1
                        }
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title)
                        .foregroundColor(Color(red: 0.0, green: 0.78, blue: 0.58))
                }
                .disabled(numberOfPeople <= (selectedOption == .pareja ? 2 : 1))
                
                Spacer()
                Text("\(numberOfPeople)")
                    .font(.title.bold())
                    .foregroundColor(Color(red: 0.0, green: 0.78, blue: 0.58))
                    .frame(minWidth: 50)
                Spacer()
                
                Button {
                    if numberOfPeople < selectedOption.maxPeople {
                        withAnimation(.spring(response: 0.3)) {
                            numberOfPeople += 1
                        }
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundColor(Color(red: 0.0, green: 0.78, blue: 0.58))
                }
                .disabled(numberOfPeople >= selectedOption.maxPeople)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 16).stroke(Color(red: 0.0, green: 0.78, blue: 0.58), lineWidth: 1.7))
            
            Text("Máximo \(selectedOption.maxPeople) personas para \(selectedOption.rawValue)")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
    
    var dateSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar.circle.fill")
                    .foregroundColor(Color(red: 0.0, green: 0.78, blue: 0.58))
                Text("Fecha de visita")
                    .font(.headline)
            }
            
            DatePicker("Selecciona fecha", selection: $selectedDate, in: Date()..., displayedComponents: .date)
                .datePickerStyle(.graphical)
                .accentColor(Color(red: 0.0, green: 0.78, blue: 0.58))
                .labelsHidden()
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).stroke(Color(red: 0.0, green: 0.78, blue: 0.58), lineWidth: 1.7))
        }
    }
    
    var priceBreakdown: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(Color(red: 0.0, green: 0.78, blue: 0.58))
                Text("Resumen de Precio")
                    .font(.headline)
                Spacer()
            }
            
            VStack(spacing: 10) {
                HStack {
                    Text("Precio base por persona:")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Spacer()
                    Text("S/ \(String(format: "%.2f", basePrice))")
                        .font(.subheadline)
                        .strikethrough()
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text("Descuento (\(place.discount)):")
                        .font(.subheadline)
                        .foregroundColor(.green)
                    Spacer()
                    Text("- S/ \(String(format: "%.2f", basePrice - priceAfterDiscount))")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
                
                HStack {
                    Text("Precio con descuento:")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Spacer()
                    Text("S/ \(String(format: "%.2f", priceAfterDiscount))")
                        .font(.subheadline.bold())
                }
                
                HStack {
                    Text("Número de personas:")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Spacer()
                    Text("× \(numberOfPeople)")
                        .font(.subheadline.bold())
                }
                
                Divider()
                
                HStack {
                    Text("TOTAL:")
                        .font(.title3.bold())
                    Spacer()
                    Text("S/ \(String(format: "%.2f", totalPrice))")
                        .font(.title2.bold())
                        .foregroundColor(Color(red: 0.0, green: 0.78, blue: 0.58))
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.gray.opacity(0.05)))
        }
    }
    
    private func bookTouristPlace() {
        guard let userId = viewModel.userSession?.uid else { return }
        isBooking = true
        
        let bookingData: [String: Any] = [
            "userId": userId,
            "origin": "Trujillo",
            "destination": place.name,
            "date": selectedDate,
            "time": "09:00 AM",
            "seatNumber": numberOfPeople,
            "status": "pending",
            "price": totalPrice,
            "paymentMethod": "pending",
            "createdAt": FieldValue.serverTimestamp(),
            "travelType": selectedOption.rawValue,
            "numberOfPeople": numberOfPeople,
            "isTouristPlace": true
        ]
        
        Firestore.firestore()
            .collection("bookings")
            .addDocument(data: bookingData) { error in
                isBooking = false
                if error == nil {
                    showSuccessAlert = true
                }
            }
    }
    
    private func getDescription(for placeName: String) -> String {
        switch placeName {
        case "Chan Chan":
            return "La ciudad de barro más grande de América precolombina. Declarada Patrimonio de la Humanidad por la UNESCO, esta antigua capital del reino Chimú te transportará a una civilización fascinante."
        case "Huacas del Sol y Luna":
            return "Impresionantes pirámides de adobe construidas por la cultura Moche. Descubre murales policromados y aprende sobre una de las civilizaciones más avanzadas del antiguo Perú."
        case "Plaza de Armas":
            return "El corazón colonial de Trujillo, rodeada de hermosas casonas y la imponente Catedral. Un lugar perfecto para admirar la arquitectura colonial y disfrutar del ambiente trujillano."
        case "Huamachuco (Plaza de Armas)":
            return "Encantadora plaza en el corazón de Huamachuco, rodeada de arquitectura colonial y moderna. Punto de encuentro de la vida social y cultural de la ciudad."
        case "Marcahuamachuco (Complejo Arqueológico)":
            return "Impresionante complejo arqueológico preinca con murallas ciclópeas. Conocido como el 'Machu Picchu del Norte', ofrece vistas espectaculares de la sierra liberteña."
        case "Laguna de Sausacocha":
            return "Hermosa laguna de aguas cristalinas rodeada de montañas. Ideal para paseos en bote, observación de aves y disfrutar de la naturaleza en su máxima expresión."
        case "Ruinas de Wiracochapampa":
            return "Centro administrativo de la cultura Wari, con una arquitectura única que muestra la influencia de esta importante civilización preinca en la región."
        case "Santiago de Chuco (Tierra de César Vallejo)":
            return "Ciudad natal del gran poeta César Vallejo. Recorre sus calles empedradas, visita su casa museo y respira el aire que inspiró algunos de los mejores poemas en español."
        default:
            return "Descubre este maravilloso destino turístico que ofrece historia, cultura y belleza natural. Una experiencia única que recordarás para siempre."
        }
    }
}
