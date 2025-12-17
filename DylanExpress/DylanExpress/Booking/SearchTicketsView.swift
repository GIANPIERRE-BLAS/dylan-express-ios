import SwiftUI
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var userLocation: CLLocation?
    @Published var locationString = "Trujillo"
    @Published var isLoadingLocation = false
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        isLoadingLocation = true
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            DispatchQueue.main.async {
                self.isLoadingLocation = false
                if let placemark = placemarks?.first {
                    self.locationString = placemark.locality ?? "Trujillo"
                }
            }
        }
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isLoadingLocation = false
        locationString = "Trujillo"
    }
}

struct TouristPlace: Identifiable {
    let id = UUID()
    let name: String
    let imageUrl: String
    let discount: String
}

struct SearchTicketsView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    @StateObject private var locationManager = LocationManager()
    @State private var origin = "Trujillo - Agencia"
    @State private var destination = ""
    @State private var selectedDate = Date()
    @State private var selectedTime = "08:00 AM"
    @State private var showOriginSheet = false
    
    let destinations = [
        "Otuzco", "Carabamba", "Salpo" , "Mache", "Quiruvilca","Sauco","Moche", "Virú", "Chao", "Santiag de Chuco",
        "Cascas", "Chepén", "Pacasmayo", "Guadalupe", "San Pedro de Lloc",
        "Huamachuco", "Quiruvilca", "Poroto", "Laredo", "Simbal"
    ]
    
    let availableTimes = [
        "06:00 AM", "08:00 AM", "10:00 AM", "12:00 PM",
        "02:00 PM", "04:00 PM", "06:00 PM", "08:00 PM"
    ]
    
    let touristPlaces: [TouristPlace] = [
        TouristPlace(name: "Balcon del Cielo, SALPO", imageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQrsrEqcNEE7TcNWeSRVBRMSFd0Ojd5Iczzxw&s", discount: "5% OFF"),
        TouristPlace(name: "Mache extremo", imageUrl: "https://www.ayniforest.com/assets/img/destinations/mache/mache_2.jpg", discount: "10% OFF"),
        TouristPlace(name: "Otuzco", imageUrl: "https://perutogethertravel.com/wp-content/uploads/2021/11/virgen-de-la-puerta.png", discount: "4% OFF"),
        TouristPlace(name: "Chan Chan", imageUrl: "https://bushop.com/peru/wp-content/uploads/sites/10/chan-chan-trujillo-portada-web.jpg", discount: "10% OFF"),
        TouristPlace(name: "Huacas del Sol y Luna", imageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQZLIeALAg8qwD3p3mV1R_U96f2VCtXiYrJ7Q&s", discount: "15% OFF"),
        TouristPlace(name: "Plaza de Armas", imageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSybhsgQXKb-iAPHXvFXGxVgAN1P2rU5a83MQ&s", discount: "5% OFF"),
        TouristPlace(name: "Huamachuco (Plaza de Armas)", imageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRmzCwjR9ovSOSCWM7gLqjRq1vJh_Z46j3lXA&s", discount: "10% OFF"),
        TouristPlace(name: "Marcahuamachuco (Complejo Arqueológico)", imageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTQWH05G-CroNSv56m2LA6V3rJbAtraIY2kyA&s", discount: "15% OFF"),
        TouristPlace(name: "Laguna de Sausacocha", imageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRbBU-aHLQgY7gKZQxhx7T9ZvTZKr3pQbKh_g&s", discount: "5% OFF"),
        TouristPlace(name: "Ruinas de Wiracochapampa", imageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTveOAyYWD4eMWHU2Q9vcosWntF1I4oOfVHmw&s", discount: "20% OFF"),
        TouristPlace(name: "Santiago de Chuco (Tierra de César Vallejo)", imageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ8MV6zc4YJPHVRHsQD9hEeDOMZizps97fa1g&s", discount: "10% OFF")
    ]
    
    var body: some View {
        ZStack {
            (isDarkMode ? Color.black : Color.white)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 30) {
                    headerSection
                    
                    touristCarousel
                    
                    searchForm
                    
                    Spacer(minLength: 30)
                }
            }
        }
        .navigationTitle("Reservar Pasaje")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .sheet(isPresented: $showOriginSheet) {
            OriginSelectionSheet(origin: $origin, locationManager: locationManager)
        }
    }
    
    var headerSection: some View {
        VStack(spacing: 15) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .foregroundColor(.blue)
                            .font(.title3)
                        Text("¿A dónde viajas hoy?")
                            .font(.title2.bold())
                            .foregroundColor(isDarkMode ? .white : .black)
                    }
                    
                    HStack(spacing: 6) {
                        Image(systemName: "location.fill")
                            .foregroundColor(Color(red: 0.0, green: 0.78, blue: 0.58))
                            .font(.caption)
                        Text("Desde: \(origin)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 25)
            .padding(.top, 20)
        }
    }
    
    var touristCarousel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(Color(red: 1, green: 0.85, blue: 0.0))
                Text("Descuentos Especiales")
                    .font(.headline)
                    .foregroundColor(isDarkMode ? .white : .black)
            }
            .padding(.horizontal, 25)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(touristPlaces) { place in
                        NavigationLink(destination: TouristPlaceView(
                            place: place,
                            origin: origin
                        )
                        .environmentObject(viewModel)) {
                            TouristCard(place: place)
                        }
                    }
                }
                .padding(.horizontal, 25)
            }
        }
    }
    
    var searchForm: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.blue)
                    Text("Origen")
                        .font(.subheadline.bold())
                        .foregroundColor(.gray)
                }
                
                Button(action: {
                    showOriginSheet = true
                }) {
                    HStack {
                        Image(systemName: "house.fill")
                            .foregroundColor(.blue)
                            .font(.title3)
                        
                        Text(origin)
                            .font(.body)
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
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "location.fill")
                        .foregroundColor(.blue)
                    Text("Destino")
                        .font(.subheadline.bold())
                        .foregroundColor(.gray)
                }
                
                Menu {
                    ForEach(destinations, id: \.self) { dest in
                        Button(dest) {
                            destination = dest
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "flag.fill")
                            .foregroundColor(.blue)
                            .font(.title3)
                        
                        Text(destination.isEmpty ? "Selecciona tu destino" : destination)
                            .foregroundColor(destination.isEmpty ? .gray : (isDarkMode ? .white : .black))
                        
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
            
            HStack(spacing: 15) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                        Text("Fecha de viaje")
                            .font(.subheadline.bold())
                            .foregroundColor(.gray)
                    }
                    
                    DatePicker("", selection: $selectedDate, in: Date()..., displayedComponents: .date)
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
            
            NavigationLink(
                destination: BusSelectionView(
                    origin: origin,
                    destination: destination,
                    date: selectedDate,
                    time: selectedTime
                ).environmentObject(viewModel)
            ) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .font(.headline)
                    Text("BUSCAR PASAJES")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    Group {
                        if destination.isEmpty {
                            Color.gray
                        } else {
                            primaryGradient
                        }
                    }
                )
                .cornerRadius(16)
            }
            .disabled(destination.isEmpty)
            .padding(.top, 10)
        }
        .padding(.horizontal, 25)
    }
}

struct TouristCard: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    let place: TouristPlace
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 8) {
                AsyncImage(url: URL(string: place.imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 120)
                        .clipped()
                } placeholder: {
                    ZStack {
                        Color.gray.opacity(0.2)
                        ProgressView()
                    }
                    .frame(width: 200, height: 120)
                }
                .frame(width: 200, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Text(place.name)
                    .font(.subheadline.bold())
                    .foregroundColor(isDarkMode ? .white : .black)
                    .lineLimit(2)
                    .frame(height: 35, alignment: .top)
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .foregroundColor(isDarkMode ? Color.gray.opacity(0.2) : Color.white)
                    .shadow(color: isDarkMode ? .clear : .gray.opacity(0.2), radius: 5, x: 0, y: 2)
            )
            
            Text(place.discount)
                .font(.caption.bold())
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().foregroundColor(Color.red))
                .padding(8)
        }
        .frame(width: 220, height: 185)
    }
}

struct OriginSelectionSheet: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    @Binding var origin: String
    @ObservedObject var locationManager: LocationManager
    @State private var manualAddress = ""
    @Environment(\.presentationMode) var presentationMode
    
    let predefinedCities = [
        "Trujillo - Agencia",
        "Carabamba - Agencia",
        "Otuzco - Agencia",
        "Salpo - Agencia",
        "Mache - Agencia",
        "Quiruvilca - Agencia",
        "Huamachuco - Agencia"
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                (isDarkMode ? Color.black : Color.white)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 25) {
                        VStack(spacing: 15) {
                            Button(action: {
                                locationManager.requestLocation()
                            }) {
                                HStack {
                                    if locationManager.isLoadingLocation {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0.0, green: 0.78, blue: 0.58)))
                                    } else {
                                        Image(systemName: "location.circle.fill")
                                            .foregroundColor(.blue)
                                            .font(.title2)
                                    }
                                    
                                    VStack(alignment: .leading) {
                                        Text("Usar mi ubicación actual")
                                            .font(.headline)
                                            .foregroundColor(isDarkMode ? .white : .black)
                                        Text("GPS")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(primaryGradient, lineWidth: 2)
                                )
                            }
                            
                            if !locationManager.locationString.isEmpty && locationManager.locationString != "Trujillo" {
                                Button(action: {
                                    origin = locationManager.locationString
                                    presentationMode.wrappedValue.dismiss()
                                }) {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                        Text("Detectado: \(locationManager.locationString)")
                                            .foregroundColor(isDarkMode ? .white : .black)
                                        Spacer()
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .foregroundColor(Color.green.opacity(0.1))
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Selecciona una agencia")
                                .font(.headline)
                                .foregroundColor(isDarkMode ? .white : .black)
                                .padding(.horizontal, 20)
                            
                            ForEach(predefinedCities, id: \.self) { city in
                                Button(action: {
                                    origin = city
                                    presentationMode.wrappedValue.dismiss()
                                }) {
                                    HStack {
                                        Image(systemName: origin == city ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(.blue)
                                        Text(city)
                                            .foregroundColor(isDarkMode ? .white : .black)
                                        Spacer()
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .foregroundColor(origin == city ? Color.gray.opacity(0.2) : Color.clear)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Selecciona tu origen")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .navigationBarItems(
                trailing: Button("Cerrar") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.blue)
            )
        }
    }
}
