import SwiftUI
import FirebaseFirestore

struct BookingConfirmationView: View {
    let booking: BookingData
    @Environment(\.dismiss) var dismiss
    @State private var showingTicket = false
    
    var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 1, green: 0.85, blue: 0.0),
                Color(red: 0.0, green: 0.78, blue: 0.58),
                Color(red: 0.0, green: 0.68, blue: 0.95)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(primaryGradient)
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.top, 40)
                
                VStack(spacing: 10) {
                    Text("¡Reserva Confirmada!")
                        .font(.title.bold())
                    
                    Text("Tu pasaje ha sido reservado exitosamente")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                VStack(spacing: 20) {
                    BookingDetailRow(
                        icon: "mappin.circle.fill",
                        title: "Ruta",
                        value: "\(booking.origin) → \(booking.destination)"
                    )
                    
                    BookingDetailRow(
                        icon: "calendar",
                        title: "Fecha",
                        value: booking.dateString
                    )
                    
                    BookingDetailRow(
                        icon: "clock.fill",
                        title: "Hora de salida",
                        value: booking.time
                    )
                    
                    if booking.isTouristPlace {
                        BookingDetailRow(
                            icon: "person.3.fill",
                            title: "Personas",
                            value: "\(booking.numberOfPeople ?? 1) persona(s)",
                            highlighted: true
                        )
                        
                        if let travelType = booking.travelType {
                            BookingDetailRow(
                                icon: "figure.2.and.child.holdinghands",
                                title: "Tipo de viaje",
                                value: travelType,
                                highlighted: false
                            )
                        }
                    } else {
                        BookingDetailRow(
                            icon: "airline.seat.recline.normal",
                            title: "Asiento",
                            value: "Nº \(booking.seatNumber)",
                            highlighted: true
                        )
                    }
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 25)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gray.opacity(0.05))
                )
                .padding(.horizontal, 20)
                
                VStack(spacing: 15) {
                    Button {
                        showingTicket = true
                    } label: {
                        HStack {
                            Image(systemName: booking.isTouristPlace ? "camera.fill" : "ticket.fill")
                            Text(booking.isTouristPlace ? "VER MI TICKET TURÍSTICO" : "VER MI BOLETO")
                        }
                        .foregroundColor(.white)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(primaryGradient)
                        .cornerRadius(16)
                    }
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("Volver al Inicio")
                            .foregroundColor(Color(red: 0.0, green: 0.78, blue: 0.58))
                            .font(.callout.bold())
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showingTicket) {
            TicketView(booking: booking)
        }
    }
}

struct BookingDetailRow: View {
    let icon: String
    let title: String
    let value: String
    var highlighted: Bool = false
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(highlighted ? Color(red: 0.0, green: 0.78, blue: 0.58) : .gray)
                .font(.title2)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(value)
                    .font(highlighted ? .title3.bold() : .body)
                    .foregroundColor(highlighted ? Color(red: 0.0, green: 0.78, blue: 0.58) : .black)
            }
            
            Spacer()
        }
    }
}

struct TicketView: View {
    let booking: BookingData
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
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
                
                ScrollView {
                    VStack(spacing: 25) {
                        VStack(spacing: 15) {
                            Image("logodylan")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 60)
                            
                            Text(booking.isTouristPlace ? "TICKET TURÍSTICO DIGITAL" : "BOLETO DIGITAL")
                                .font(.title2.bold())
                                .foregroundColor(Color(red: 0.0, green: 0.78, blue: 0.58))
                            
                            if booking.isTouristPlace {
                                Image(systemName: "camera.viewfinder")
                                    .font(.system(size: 40))
                                    .foregroundColor(Color(red: 1, green: 0.85, blue: 0.0))
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
                                    
                                    Image(systemName: booking.isTouristPlace ? "arrow.right.circle.fill" : "arrow.right.circle.fill")
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
                                    .padding(.bottom, 25)
                                } else {
                                    // Vista para pasaje de bus
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
                                    .padding(.bottom, 25)
                                }
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
                            
                            VStack(spacing: 15) {
                                Text("CÓDIGO DE RESERVA")
                                    .font(.caption.bold())
                                    .foregroundColor(.gray)
                                
                                Text(booking.id.prefix(8).uppercased())
                                    .font(.title.bold())
                                    .tracking(3)
                                
                                Text("Estado: CONFIRMADO")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 5)
                                    .background(
                                        Capsule()
                                            .fill(Color.green.opacity(0.1))
                                    )
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 25)
                            .background(Color.white)
                            .cornerRadius(20)
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(spacing: 10) {
                            Text(booking.isTouristPlace ? "Presentar este ticket al llegar al punto de encuentro" : "Presentar este boleto digital al abordar")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                            
                            HStack(spacing: 5) {
                                Image(systemName: "info.circle.fill")
                                    .font(.caption2)
                                Text(booking.isTouristPlace ? "Llegar al punto de encuentro a la hora indicada" : "Llegar 15 minutos antes de la hora de salida")
                                    .font(.caption2)
                            }
                            .foregroundColor(.orange)
                        }
                        .padding(.horizontal, 30)
                        
                        Spacer(minLength: 30)
                    }
                }
            }
            .navigationTitle(booking.isTouristPlace ? "Mi Ticket" : "Mi Boleto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func getTravelIcon(_ type: String) -> String {
        switch type {
        case "Solo": return "person.fill"
        case "En Pareja": return "person.2.fill"
        case "Familia": return "figure.2.and.child.holdinghands"
        case "Grupo": return "person.3.fill"
        default: return "person.fill"
        }
    }
}
