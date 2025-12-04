import SwiftUI
import FirebaseFirestore
import CoreImage.CIFilterBuiltins

struct TicketDetailView: View {
    let bookingId: String
    
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var booking: BookingData?
    @State private var isLoading = true
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 1, green: 0.85, blue: 0.0).opacity(0.1),
                    Color(red: 0.0, green: 0.78, blue: 0.58).opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if isLoading {
                ProgressView("Generando ticket...")
            } else if let booking = booking {
                ScrollView {
                    VStack(spacing: 30) {
                        VStack(spacing: 15) {
                            Image(systemName: booking.status == "paid" ? "checkmark.circle.fill" : "clock.fill")
                                .font(.system(size: 70))
                                .foregroundColor(booking.status == "paid" ? .green : .orange)
                            
                            Text(booking.status == "paid" ? "¡Pago Confirmado!" : "Reserva Pendiente")
                                .font(.title.bold())
                            
                            if booking.status == "pending" {
                                Text("Completa tu pago en 24 horas")
                                    .font(.subheadline)
                                    .foregroundColor(.orange)
                            }
                        }
                        .padding(.top, 30)
                        
                        VStack(spacing: 0) {
                            VStack(spacing: 20) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("ORIGEN")
                                            .font(.caption.bold())
                                            .foregroundColor(.gray)
                                        Text(booking.origin)
                                            .font(.title2.bold())
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
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 5) {
                                        Text("MÉTODO DE PAGO")
                                            .font(.caption.bold())
                                            .foregroundColor(.gray)
                                        Text(paymentMethodName(booking.paymentMethod))
                                            .font(.subheadline.bold())
                                    }
                                }
                                .padding(.horizontal, 25)
                                .padding(.bottom, 25)
                            }
                            .background(Color.white)
                            .cornerRadius(20)
                            
                            HStack(spacing: 0) {
                                Circle()
                                    .fill(Color(red: 1, green: 0.85, blue: 0.0).opacity(0.1))
                                    .frame(width: 30, height: 30)
                                    .offset(x: -15)
                                
                                Spacer()
                                
                                ForEach(0..<20) { _ in
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 5, height: 2)
                                }
                                
                                Spacer()
                                
                                Circle()
                                    .fill(Color(red: 1, green: 0.85, blue: 0.0).opacity(0.1))
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
                                    .tracking(3)
                                
                                if let qrImage = generateQRCode(from: booking.id) {
                                    Image(uiImage: qrImage)
                                        .interpolation(.none)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 200, height: 200)
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(12)
                                }
                                
                                HStack(spacing: 5) {
                                    Circle()
                                        .fill(booking.status == "paid" ? Color.green : Color.orange)
                                        .frame(width: 10, height: 10)
                                    Text(booking.status == "paid" ? "PAGADO" : "PENDIENTE DE PAGO")
                                        .font(.caption.bold())
                                        .foregroundColor(booking.status == "paid" ? .green : .orange)
                                }
                                .padding(.horizontal, 15)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill((booking.status == "paid" ? Color.green : Color.orange).opacity(0.1))
                                )
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 30)
                            .background(Color.white)
                            .cornerRadius(20)
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
                        
                        Button {
                            dismiss()
                        } label: {
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
        .navigationTitle("Mi Boletos")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            loadBooking()
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
