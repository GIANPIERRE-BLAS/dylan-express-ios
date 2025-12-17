import SwiftUI
import FirebaseFirestore
import CoreImage.CIFilterBuiltins

struct TicketDetailView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    let bookingId: String
    
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var booking: BookingData?
    @State private var isLoading = true
    @State private var userData: TicketUserData?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 1, green: 0.85, blue: 0.0).opacity(isDarkMode ? 0.05 : 0.1),
                    Color(red: 0.0, green: 0.78, blue: 0.58).opacity(isDarkMode ? 0.05 : 0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            if isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(1.3)
                    Text("Generando ticket...")
                        .foregroundColor(.gray)
                }
            } else if let booking = booking {
                ScrollView {
                    VStack(spacing: 30) {
                        VStack(spacing: 15) {
                            Image(systemName: booking.status == "paid" ? "checkmark.circle.fill" : "clock.fill")
                                .font(.system(size: 70))
                                .foregroundColor(booking.status == "paid" ? .green : .orange)
                            
                            Text(booking.status == "paid" ? "¡Pago Confirmado!" : "Reserva Pendiente")
                                .font(.title.bold())
                                .foregroundColor(isDarkMode ? .white : .black)
                            
                            if booking.status == "pending" {
                                Text("Completa tu pago en 24 horas")
                                    .font(.subheadline)
                                    .foregroundColor(.orange)
                            }
                        }
                        .padding(.top, 30)
                        
                        if let userData = userData {
                            userInfoSection(userData: userData)
                        }
                        
                        VStack(spacing: 0) {
                            VStack(spacing: 20) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("ORIGEN")
                                            .font(.caption.bold())
                                            .foregroundColor(.gray)
                                        Text(booking.origin)
                                            .font(.title2.bold())
                                            .foregroundColor(isDarkMode ? .white : .black)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "arrow.right.circle.fill")
                                        .font(.title)
                                        .foregroundColor(Color(red: 0.0, green: 0.78, blue: 0.58))
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 5) {
                                        Text("DESTINO")
                                            .font(.caption.bold())
                                            .foregroundColor(.gray)
                                        Text(booking.destination)
                                            .font(.title2.bold())
                                            .foregroundColor(isDarkMode ? .white : .black)
                                    }
                                }
                                .padding(.horizontal, 25)
                                .padding(.top, 25)
                                
                                Divider()
                                    .padding(.horizontal, 25)
                                
                                if booking.isTouristPlace {
                                    VStack(spacing: 20) {
                                        HStack(spacing: 30) {
                                            VStack(spacing: 8) {
                                                Image(systemName: "calendar")
                                                    .font(.title2)
                                                    .foregroundColor(Color(red: 0.0, green: 0.78, blue: 0.58))
                                                Text(booking.dateString)
                                                    .font(.subheadline.bold())
                                                    .foregroundColor(isDarkMode ? .white : .black)
                                                Text("FECHA")
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                            
                                            VStack(spacing: 8) {
                                                Image(systemName: "clock.fill")
                                                    .font(.title2)
                                                    .foregroundColor(Color(red: 0.0, green: 0.78, blue: 0.58))
                                                Text(booking.time)
                                                    .font(.subheadline.bold())
                                                    .foregroundColor(isDarkMode ? .white : .black)
                                                Text("HORA")
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        
                                        HStack(spacing: 30) {
                                            VStack(spacing: 8) {
                                                Image(systemName: "person.3.fill")
                                                    .font(.title2)
                                                    .foregroundColor(Color(red: 1, green: 0.85, blue: 0.0))
                                                Text("\(booking.numberOfPeople ?? 1)")
                                                    .font(.subheadline.bold())
                                                    .foregroundColor(isDarkMode ? .white : .black)
                                                Text("PERSONAS")
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                            
                                            if let travelType = booking.travelType {
                                                VStack(spacing: 8) {
                                                    Image(systemName: getTravelIcon(travelType))
                                                        .font(.title2)
                                                        .foregroundColor(Color(red: 1, green: 0.85, blue: 0.0))
                                                    Text(travelType)
                                                        .font(.subheadline.bold())
                                                        .foregroundColor(isDarkMode ? .white : .black)
                                                    Text("TIPO")
                                                        .font(.caption)
                                                        .foregroundColor(.gray)
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 25)
                                } else {
                                    HStack(spacing: 30) {
                                        VStack(spacing: 8) {
                                            Image(systemName: "calendar")
                                                .font(.title2)
                                                .foregroundColor(Color(red: 0.0, green: 0.78, blue: 0.58))
                                            Text(booking.dateString)
                                                .font(.subheadline.bold())
                                                .foregroundColor(isDarkMode ? .white : .black)
                                            Text("FECHA")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        
                                        VStack(spacing: 8) {
                                            Image(systemName: "clock.fill")
                                                .font(.title2)
                                                .foregroundColor(Color(red: 0.0, green: 0.78, blue: 0.58))
                                            Text(booking.time)
                                                .font(.subheadline.bold())
                                                .foregroundColor(isDarkMode ? .white : .black)
                                            Text("HORA")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        
                                        VStack(spacing: 8) {
                                            Image(systemName: "airline.seat.recline.normal")
                                                .font(.title2)
                                                .foregroundColor(Color(red: 0.0, green: 0.78, blue: 0.58))
                                            Text("Nº \(booking.seatNumber)")
                                                .font(.subheadline.bold())
                                                .foregroundColor(isDarkMode ? .white : .black)
                                            Text("ASIENTO")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding(.horizontal, 25)
                                }
                                
                                Divider()
                                    .padding(.horizontal, 25)
                                
                                HStack {
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("PRECIO")
                                            .font(.caption.bold())
                                            .foregroundColor(.gray)
                                        Text("S/ \(String(format: "%.2f", booking.price))")
                                            .font(.title3.bold())
                                            .foregroundColor(isDarkMode ? .white : .black)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 5) {
                                        Text("MÉTODO DE PAGO")
                                            .font(.caption.bold())
                                            .foregroundColor(.gray)
                                        Text(paymentMethodName(booking.paymentMethod))
                                            .font(.subheadline.bold())
                                            .foregroundColor(isDarkMode ? .white : .black)
                                    }
                                }
                                .padding(.horizontal, 25)
                                .padding(.bottom, 25)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundColor(isDarkMode ? Color.gray.opacity(0.2) : Color.white)
                            )
                            
                            HStack(spacing: 0) {
                                Circle()
                                    .foregroundColor(Color(red: 1, green: 0.85, blue: 0.0).opacity(isDarkMode ? 0.05 : 0.1))
                                    .frame(width: 30, height: 30)
                                    .offset(x: -15)
                                
                                Spacer()
                                
                                ForEach(0..<20) { _ in
                                    Rectangle()
                                        .foregroundColor(Color.gray.opacity(0.3))
                                        .frame(width: 5, height: 2)
                                }
                                
                                Spacer()
                                
                                Circle()
                                    .foregroundColor(Color(red: 1, green: 0.85, blue: 0.0).opacity(isDarkMode ? 0.05 : 0.1))
                                    .frame(width: 30, height: 30)
                                    .offset(x: 15)
                            }
                            .frame(height: 1)
                            
                            VStack(spacing: 20) {
                                Text("CÓDIGO DE RESERVA")
                                    .font(.caption.bold())
                                    .foregroundColor(.gray)
                                
                                Text(booking.id.prefix(8).uppercased())
                                    .font(.title.bold())
                                    .foregroundColor(isDarkMode ? .white : .black)
                                    .tracking(3)
                                
                                if let qrImage = generateQRCode(from: booking.id) {
                                    Image(uiImage: qrImage)
                                        .interpolation(.none)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 200, height: 200)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .foregroundColor(isDarkMode ? Color.gray.opacity(0.95) : Color.white)
                                        )
                                }
                                
                                HStack(spacing: 5) {
                                    Circle()
                                        .foregroundColor(booking.status == "paid" ? Color.green : Color.orange)
                                        .frame(width: 10, height: 10)
                                    Text(booking.status == "paid" ? "PAGADO" : "PENDIENTE DE PAGO")
                                        .font(.caption.bold())
                                        .foregroundColor(booking.status == "paid" ? .green : .orange)
                                }
                                .padding(.horizontal, 15)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .foregroundColor((booking.status == "paid" ? Color.green : Color.orange).opacity(0.1))
                                )
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 30)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundColor(isDarkMode ? Color.gray.opacity(0.2) : Color.white)
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
                            if booking.status == "paid" {
                                HStack(spacing: 8) {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(.blue)
                                    Text(booking.isTouristPlace ? "Presentar este ticket en el punto de encuentro" : "Presentar este ticket al abordar")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            } else {
                                HStack(spacing: 8) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.orange)
                                    Text("Acércate a la agencia para completar tu pago")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            HStack(spacing: 8) {
                                Image(systemName: "clock.fill")
                                    .foregroundColor(.orange)
                                    .font(.caption)
                                Text(booking.isTouristPlace ? "Llegar a la hora indicada" : "Llegar 15 minutos antes de la salida")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal, 30)
                        
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("VOLVER AL INICIO")
                                .foregroundColor(.white)
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(primaryGradient)
                                .cornerRadius(16)
                        }
                        .padding(.horizontal, 30)
                        
                        Spacer(minLength: 30)
                    }
                }
            }
        }
        .navigationTitle("Mi Boleto")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            loadBooking()
            loadUserData()
        }
    }
    
    private func userInfoSection(userData: TicketUserData) -> some View {
        VStack(spacing: 15) {
            HStack(spacing: 15) {
                if let imageBase64 = userData.profileImageBase64,
                   let imageData = Data(base64Encoded: imageBase64),
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 70, height: 70)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(primaryGradient, lineWidth: 3)
                        )
                } else {
                    ZStack {
                        Circle()
                            .foregroundColor(.clear)
                            .background(primaryGradient)
                            .frame(width: 70, height: 70)
                            .clipShape(Circle())
                        
                        Text(userData.fullName.prefix(1).uppercased())
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "person.fill")
                            .foregroundColor(.blue)
                            .font(.caption)
                        Text(userData.fullName)
                            .font(.headline)
                            .foregroundColor(isDarkMode ? .white : .black)
                    }
                    
                    HStack(spacing: 6) {
                        Image(systemName: "creditcard.fill")
                            .foregroundColor(.blue)
                            .font(.caption)
                        Text("DNI: \(userData.dni)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    HStack(spacing: 6) {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.blue)
                            .font(.caption)
                        Text(userData.phoneNumber)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .foregroundColor(isDarkMode ? Color.gray.opacity(0.2) : Color.white)
                    .shadow(color: isDarkMode ? .clear : Color.black.opacity(0.05), radius: 8)
            )
        }
        .padding(.horizontal, 20)
    }
    
    func loadUserData() {
        guard let userId = viewModel.userSession?.uid else { return }
        
        Firestore.firestore()
            .collection("users")
            .document(userId)
            .getDocument { document, error in
                if let document = document, document.exists {
                    let data = document.data() ?? [:]
                    
                    let phoneNumber = data["phoneNumber"] as? String
                        ?? data["phone"] as? String
                        ?? data["telefono"] as? String
                        ?? ""
                    
                    userData = TicketUserData(
                        id: document.documentID,
                        email: data["email"] as? String ?? "",
                        fullName: data["fullName"] as? String ?? "",
                        dni: data["dni"] as? String ?? "",
                        phoneNumber: phoneNumber,
                        profileImageBase64: data["profileImageBase64"] as? String
                    )
                    
                    print("DEBUG - User data loaded:")
                    print("- Name: \(userData?.fullName ?? "N/A")")
                    print("- DNI: \(userData?.dni ?? "N/A")")
                    print("- Phone: \(userData?.phoneNumber ?? "N/A")")
                } else {
                    print("DEBUG - User document does not exist or error: \(error?.localizedDescription ?? "unknown")")
                }
            }
    }
    
    func loadBooking() {
        Firestore.firestore().collection("bookings")
            .document(bookingId)
            .getDocument { document, error in
                isLoading = false
                
                if let document = document, document.exists {
                    let data = document.data() ?? [:]
                    
                    if let userId = data["userId"] as? String,
                       let origin = data["origin"] as? String,
                       let destination = data["destination"] as? String,
                       let timestamp = data["date"] as? Timestamp,
                       let time = data["time"] as? String,
                       let seatNumber = data["seatNumber"] as? Int,
                       let price = data["price"] as? Double,
                       let status = data["status"] as? String,
                       let paymentMethod = data["paymentMethod"] as? String,
                       let createdTimestamp = data["createdAt"] as? Timestamp {
                        
                        let placeType = data["placeType"] as? String
                        let isTouristPlace = placeType == "tourist"
                        let travelType = data["travelType"] as? String
                        let numberOfPeople = data["numberOfPeople"] as? Int
                        
                        booking = BookingData(
                            id: document.documentID,
                            userId: userId,
                            origin: origin,
                            destination: destination,
                            date: timestamp.dateValue(),
                            time: time,
                            seatNumber: seatNumber,
                            status: status,
                            price: price,
                            paymentMethod: paymentMethod,
                            createdAt: createdTimestamp.dateValue(),
                            isTouristPlace: isTouristPlace,
                            travelType: travelType,
                            numberOfPeople: numberOfPeople
                        )
                    }
                }
            }
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"
        
        if let outputImage = filter.outputImage {
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledImage = outputImage.transformed(by: transform)
            
            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        
        return nil
    }
    
    func paymentMethodName(_ method: String) -> String {
        switch method {
        case "yape": return "Yape"
        case "card": return "Tarjeta"
        case "cash": return "Efectivo"
        default: return method
        }
    }
    
    private func getTravelIcon(_ type: String) -> String {
        switch type {
        case "Solo": return "person.fill"
        case "Grupo": return "person.3.fill"
        default: return "person.fill"
        }
    }
}

struct TicketUserData {
    let id: String
    let email: String
    let fullName: String
    let dni: String
    let phoneNumber: String
    let profileImageBase64: String?
}
