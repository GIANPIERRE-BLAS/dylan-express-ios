import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct FavoriteTripsView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    @State private var favoriteTrips: [FavoriteTrip] = []
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            (isDarkMode ? Color.black : Color.white)
                .ignoresSafeArea()
            
            if isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.primaryGreen))
                        .scaleEffect(1.3)
                    Text("Cargando favoritos...")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            } else if favoriteTrips.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 18) {
                        ForEach(favoriteTrips) { favorite in
                            FavoriteTripCard(favorite: favorite, onRemove: {
                                removeFavorite(favorite)
                            })
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Viajes Favoritos")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onAppear {
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
                
                Image(systemName: "heart.slash.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
            }
            
            VStack(spacing: 10) {
                Text("Sin Favoritos Aún")
                    .font(.title2.bold())
                    .foregroundColor(isDarkMode ? .white : .black)
                
                Text("Guarda tus viajes favoritos para\nacceder a ellos rápidamente")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            
            NavigationLink(destination: MyTripsView().environmentObject(viewModel)) {
                HStack {
                    Image(systemName: "bus.fill")
                    Text("Ver Mis Viajes")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(primaryGradient)
                .cornerRadius(16)
                .padding(.horizontal, 40)
            }
            
            Spacer()
        }
    }
    
    private func loadFavorites() {
        guard let userId = viewModel.userSession?.uid else { return }
        
        isLoading = true
        
        Firestore.firestore()
            .collection("favorites")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { snapshot, error in
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    if let error = error {
                        print("Error loading favorites: \(error.localizedDescription)")
                        return
                    }
                    
                    if let docs = snapshot?.documents {
                        self.favoriteTrips = docs.compactMap { doc in
                            let data = doc.data()
                            
                            guard let userId = data["userId"] as? String,
                                  let bookingId = data["bookingId"] as? String,
                                  let origin = data["origin"] as? String,
                                  let destination = data["destination"] as? String else {
                                print("Missing required fields in favorite: \(doc.documentID)")
                                return nil
                            }
                            
                            let timestamp = data["date"] as? Timestamp
                            let date = timestamp?.dateValue() ?? Date()
                            let time = data["time"] as? String ?? "08:00 AM"
                            let price = data["price"] as? Double ?? 0.0
                            let seatNumber = data["seatNumber"] as? Int
                            let isTouristPlace = data["isTouristPlace"] as? Bool ?? false
                            let numberOfPeople = data["numberOfPeople"] as? Int
                            let addedAtTimestamp = data["addedAt"] as? Timestamp
                            let addedAt = addedAtTimestamp?.dateValue() ?? Date()
                            
                            return FavoriteTrip(
                                id: doc.documentID,
                                userId: userId,
                                bookingId: bookingId,
                                origin: origin,
                                destination: destination,
                                date: date,
                                time: time,
                                seatNumber: seatNumber,
                                price: price,
                                isTouristPlace: isTouristPlace,
                                numberOfPeople: numberOfPeople,
                                addedAt: addedAt
                            )
                        }
                        
                        print("Loaded \(self.favoriteTrips.count) favorites")
                    }
                }
            }
    }
    
    private func removeFavorite(_ favorite: FavoriteTrip) {
        Firestore.firestore()
            .collection("favorites")
            .document(favorite.id)
            .delete { error in
                if error == nil {
                    DispatchQueue.main.async {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            self.favoriteTrips.removeAll { $0.id == favorite.id }
                        }
                    }
                }
            }
    }
}

// MARK: - Models
struct FavoriteTrip: Identifiable {
    let id: String
    let userId: String
    let bookingId: String
    let origin: String
    let destination: String
    let date: Date
    let time: String
    let seatNumber: Int?
    let price: Double
    let isTouristPlace: Bool
    let numberOfPeople: Int?
    let addedAt: Date
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: date)
    }
}

// MARK: - Favorite Trip Card
struct FavoriteTripCard: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    let favorite: FavoriteTrip
    let onRemove: () -> Void
    
    @State private var showingRemoveAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header con badge de favorito
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "heart.fill")
                        .font(.caption)
                        .foregroundColor(.red)
                    
                    Text("Favorito")
                        .font(.caption.bold())
                        .foregroundColor(.red)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .foregroundColor(Color.red.opacity(0.1))
                )
                
                Spacer()
                
                Button(action: {
                    showingRemoveAlert = true
                }) {
                    Image(systemName: "heart.slash.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.red)
                        .padding(8)
                        .background(
                            Circle()
                                .foregroundColor(isDarkMode ? Color.gray.opacity(0.3) : Color.red.opacity(0.1))
                        )
                }
            }
            .padding()
            .background(isDarkMode ? Color.gray.opacity(0.1) : Color.gray.opacity(0.05))
            
            // Trip details
            VStack(spacing: 18) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(favorite.origin)
                            .font(.title3.bold())
                            .foregroundColor(isDarkMode ? .white : .black)
                        Text(favorite.time)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Image(systemName: favorite.isTouristPlace ? "camera.viewfinder" : "arrow.right")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(favorite.destination)
                            .font(.title3.bold())
                            .foregroundColor(isDarkMode ? .white : .black)
                        Text(favorite.dateString)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Divider()
                
                HStack {
                    if favorite.isTouristPlace {
                        HStack(spacing: 6) {
                            Image(systemName: "person.3.fill")
                                .foregroundColor(.blue)
                            Text("\(favorite.numberOfPeople ?? 1) persona(s)")
                                .font(.subheadline.bold())
                                .foregroundColor(.blue)
                        }
                    } else {
                        if let seat = favorite.seatNumber {
                            HStack(spacing: 6) {
                                Image(systemName: "airline.seat.recline.normal")
                                    .foregroundColor(.blue)
                                Text("Asiento \(seat)")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 6) {
                        Image(systemName: favorite.isTouristPlace ? "mappin.circle.fill" : "bus.fill")
                            .foregroundColor(.blue)
                        Text(favorite.isTouristPlace ? "Tour" : "Bus")
                            .font(.caption.bold())
                            .foregroundColor(.blue)
                    }
                }
                
                HStack {
                    Text("Total: S/ \(String(format: "%.2f", favorite.price))")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.caption)
                        Text("Guardado: \(timeAgo(favorite.addedAt))")
                            .font(.caption)
                    }
                    .foregroundColor(.gray)
                }
            }
            .padding()
            
            Divider()
            
            // Actions
            HStack(spacing: 12) {
                NavigationLink(destination: TicketDetailView(bookingId: favorite.bookingId)) {
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
                    // Acción para reservar nuevamente
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.clockwise")
                        Text("Reservar")
                    }
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.7)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .cornerRadius(12)
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
        .alert(isPresented: $showingRemoveAlert) {
            Alert(
                title: Text("Quitar de Favoritos"),
                message: Text("¿Estás seguro de que quieres quitar este viaje de tus favoritos?"),
                primaryButton: .destructive(Text("Quitar")) {
                    onRemove()
                },
                secondaryButton: .cancel(Text("Cancelar"))
            )
        }
    }
    
    private func timeAgo(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.minute, .hour, .day], from: date, to: now)
        
        if let day = components.day, day > 0 {
            return "hace \(day)d"
        } else if let hour = components.hour, hour > 0 {
            return "hace \(hour)h"
        } else if let minute = components.minute, minute > 0 {
            return "hace \(minute)m"
        } else {
            return "ahora"
        }
    }
}
