import SwiftUI
import MapKit
import Combine

class TripSimulationViewModel: ObservableObject {
    @Published var vehiclePosition: CLLocationCoordinate2D
    @Published var progress: Double = 0.0
    @Published var isSimulating: Bool = false
    @Published var hasCompleted: Bool = false
    @Published var routeCoordinates: [CLLocationCoordinate2D] = []
    @Published var region: MKCoordinateRegion
    @Published var mapAnnotations: [CustomAnnotation] = []
    @Published var pulseScale: CGFloat = 1.0
    @Published var spinnerRotation: Double = 0
    @Published var completionScale: CGFloat = 0.5
    @Published var estimatedArrival: String = "Calculando..."
    @Published var distanceRemaining: String = "Calculando..."
    @Published var totalDistance: String = "0 km"
    @Published var totalDurationText: String = "0 min"
    
    let booking: BookingData
    
    private var timer: Timer?
    private var startTime: Date?
    private var animationTimer: Timer?
    private let simulationDuration: TimeInterval = 15.0
    private let averageSpeedKmh: Double = 55.0
    
    private let locationDatabase: [String: CLLocationCoordinate2D] = [
        "Trujillo": CLLocationCoordinate2D(latitude: -8.1116, longitude: -79.0288),
        "Trujillo - Agencia": CLLocationCoordinate2D(latitude: -8.1116, longitude: -79.0288),
        "Sauco": CLLocationCoordinate2D(latitude: -8.1667, longitude: -78.5833),
        "Sauco - Agencia": CLLocationCoordinate2D(latitude: -8.1667, longitude: -78.5833),
        "Carabamba": CLLocationCoordinate2D(latitude: -7.9833, longitude: -78.7167),
        "Carabamba - Agencia": CLLocationCoordinate2D(latitude: -7.9833, longitude: -78.7167),
        "Otuzco": CLLocationCoordinate2D(latitude: -7.9028, longitude: -78.5686),
        "Otuzco - Agencia": CLLocationCoordinate2D(latitude: -7.9028, longitude: -78.5686),
        "Salpo": CLLocationCoordinate2D(latitude: -7.9667, longitude: -78.3833),
        "Salpo - Agencia": CLLocationCoordinate2D(latitude: -7.9667, longitude: -78.3833),
        "Mache": CLLocationCoordinate2D(latitude: -7.7167, longitude: -78.8333),
        "Mache - Agencia": CLLocationCoordinate2D(latitude: -7.7167, longitude: -78.8333),
        "Quiruvilca": CLLocationCoordinate2D(latitude: -7.9833, longitude: -78.3167),
        "Quiruvilca - Agencia": CLLocationCoordinate2D(latitude: -7.9833, longitude: -78.3167),
        "Moche": CLLocationCoordinate2D(latitude: -8.1722, longitude: -79.0092),
        "Virú": CLLocationCoordinate2D(latitude: -8.4167, longitude: -78.7500),
        "Chao": CLLocationCoordinate2D(latitude: -8.5500, longitude: -78.6833),
        "Santiago de Chuco": CLLocationCoordinate2D(latitude: -8.1444, longitude: -78.1731),
        "Cascas": CLLocationCoordinate2D(latitude: -7.4833, longitude: -78.8167),
        "Chepén": CLLocationCoordinate2D(latitude: -7.2261, longitude: -79.4275),
        "Pacasmayo": CLLocationCoordinate2D(latitude: -7.4014, longitude: -79.5714),
        "Guadalupe": CLLocationCoordinate2D(latitude: -7.2500, longitude: -79.4667),
        "San Pedro de Lloc": CLLocationCoordinate2D(latitude: -7.4289, longitude: -79.5044),
        "Huamachuco": CLLocationCoordinate2D(latitude: -7.8167, longitude: -78.0500),
        "Huamachuco - Agencia": CLLocationCoordinate2D(latitude: -7.8167, longitude: -78.0500),
        "Poroto": CLLocationCoordinate2D(latitude: -8.0167, longitude: -78.7667),
        "Laredo": CLLocationCoordinate2D(latitude: -8.0906, longitude: -78.9611),
        "Simbal": CLLocationCoordinate2D(latitude: -7.9500, longitude: -78.8167),
        "Huanchaco": CLLocationCoordinate2D(latitude: -8.0786, longitude: -79.1222),
        "Chan Chan": CLLocationCoordinate2D(latitude: -8.1056, longitude: -79.0747)
    ]
    
    init(booking: BookingData) {
        self.booking = booking
        
        let originCoord = locationDatabase[booking.origin] ?? CLLocationCoordinate2D(latitude: -8.1116, longitude: -79.0288)
        let destinationCoord = locationDatabase[booking.destination] ?? CLLocationCoordinate2D(latitude: -8.1667, longitude: -78.5833)
        
        self.vehiclePosition = originCoord
        
        // Inicializamos valores por defecto obligatorios primero
        self.region = MKCoordinateRegion(
            center: originCoord,
            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        )
        
        // AHORA sí podemos usar self y llamar métodos
        let distanceKm = haversineDistance(from: originCoord, to: destinationCoord)
        self.totalDistance = String(format: "%.1f km", distanceKm)
        
        let estimatedMinutes = Int((distanceKm / averageSpeedKmh) * 60.0)
        if estimatedMinutes < 60 {
            self.totalDurationText = "\(estimatedMinutes) min"
        } else {
            let hours = estimatedMinutes / 60
            let mins = estimatedMinutes % 60
            self.totalDurationText = "\(hours)h \(mins)min"
        }
        
        // Región centrada correctamente
        let centerLat = (originCoord.latitude + destinationCoord.latitude) / 2
        let centerLon = (originCoord.longitude + destinationCoord.longitude) / 2
        let latDelta = abs(originCoord.latitude - destinationCoord.latitude) * 3.2
        let lonDelta = abs(originCoord.longitude - destinationCoord.longitude) * 3.2
        
        self.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
            span: MKCoordinateSpan(
                latitudeDelta: max(latDelta, 0.6),
                longitudeDelta: max(lonDelta, 0.6)
            )
        )
    }
    
    private func haversineDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let earthRadius = 6371.0
        
        let dLat = (to.latitude - from.latitude) * .pi / 180.0
        let dLon = (to.longitude - from.longitude) * .pi / 180.0
        
        let a = sin(dLat/2) * sin(dLat/2) +
                cos(from.latitude * .pi / 180.0) * cos(to.latitude * .pi / 180.0) *
                sin(dLon/2) * sin(dLon/2)
        
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return earthRadius * c
    }
    
    func setupRoute() {
        let originCoord = locationDatabase[booking.origin] ?? CLLocationCoordinate2D(latitude: -8.1116, longitude: -79.0288)
        let destinationCoord = locationDatabase[booking.destination] ?? CLLocationCoordinate2D(latitude: -8.1667, longitude: -78.5833)
        
        routeCoordinates = generateCurvedRoute(from: originCoord, to: destinationCoord, points: 150)
        updateAnnotations()
    }
    
    private func generateCurvedRoute(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D, points: Int) -> [CLLocationCoordinate2D] {
        var coordinates: [CLLocationCoordinate2D] = []
        
        for i in 0...points {
            let fraction = Double(i) / Double(points)
            let lat = start.latitude + (end.latitude - start.latitude) * fraction
            let lon = start.longitude + (end.longitude - start.longitude) * fraction
            
            let curveOffsetLat = sin(fraction * .pi * 8) * 0.012
            let curveOffsetLon = cos(fraction * .pi * 6) * 0.008
            
            coordinates.append(CLLocationCoordinate2D(
                latitude: lat + curveOffsetLat,
                longitude: lon + curveOffsetLon
            ))
        }
        return coordinates
    }
    
    private func updateAnnotations() {
        let originCoord = locationDatabase[booking.origin] ?? routeCoordinates.first!
        let destinationCoord = locationDatabase[booking.destination] ?? routeCoordinates.last!
        
        mapAnnotations = [
            CustomAnnotation(coordinate: originCoord, title: booking.origin, type: .origin),
            CustomAnnotation(coordinate: destinationCoord, title: booking.destination, type: .destination),
            CustomAnnotation(coordinate: vehiclePosition, title: "Combi", type: .vehicle)
        ]
    }
    
    func startSimulation() {
        guard !routeCoordinates.isEmpty else { return }
        isSimulating = true
        startTime = Date()
        pulseScale = 1.2
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { [weak self] _ in
            self?.updateSimulation()
        }
        
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.updateSpinner()
        }
    }
    
    private func updateSpinner() {
        DispatchQueue.main.async {
            self.spinnerRotation += 10
            if self.spinnerRotation >= 360 { self.spinnerRotation = 0 }
        }
    }
    
    private func updateSimulation() {
        guard let startTime = startTime else { return }
        let elapsed = Date().timeIntervalSince(startTime)
        let progress = min(elapsed / simulationDuration, 1.0)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.progress = progress
            
            let index = Int(progress * Double(self.routeCoordinates.count - 1))
            if index < self.routeCoordinates.count {
                self.vehiclePosition = self.routeCoordinates[index]
                
                if let vehicleAnnotation = self.mapAnnotations.first(where: { $0.type == .vehicle }) {
                    vehicleAnnotation.coordinate = self.vehiclePosition
                }
                
                let remainingKm = self.haversineDistance(from: self.vehiclePosition, to: self.routeCoordinates.last!)
                self.distanceRemaining = String(format: "%.1f km", remainingKm)
                
                let remainingSeconds = max(self.simulationDuration - elapsed, 0)
                let minutes = Int(remainingSeconds) / 60
                let seconds = Int(remainingSeconds) % 60
                if minutes > 0 {
                    self.estimatedArrival = "Llegas en \(minutes + 1) min"
                } else {
                    self.estimatedArrival = "Llegas en \(seconds) seg"
                }
            }
            
            if progress >= 1.0 {
                self.completeTrip()
            }
        }
    }
    
    private func completeTrip() {
        isSimulating = false
        hasCompleted = true
        progress = 1.0
        timer?.invalidate()
        animationTimer?.invalidate()
        timer = nil
        animationTimer = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.completionScale = 1.0
        }
    }
    
    func resetSimulation() {
        isSimulating = false
        progress = 0.0
        hasCompleted = false
        startTime = nil
        completionScale = 0.5
        timer?.invalidate()
        animationTimer?.invalidate()
        timer = nil
        animationTimer = nil
        
        vehiclePosition = routeCoordinates.first ?? vehiclePosition
        updateAnnotations()
        centerOnRoute()
    }
    
    func centerOnRoute() {
        guard let first = routeCoordinates.first, let last = routeCoordinates.last else { return }
        
        let centerLat = (first.latitude + last.latitude) / 2
        let centerLon = (first.longitude + last.longitude) / 2
        let latDelta = abs(first.latitude - last.latitude) * 3.2
        let lonDelta = abs(first.longitude - last.longitude) * 3.2
        
        region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
            span: MKCoordinateSpan(
                latitudeDelta: max(latDelta, 0.6),
                longitudeDelta: max(lonDelta, 0.6)
            )
        )
    }
    
    func followVehicle() {
        region = MKCoordinateRegion(
            center: vehiclePosition,
            span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
        )
    }
    
    func zoomIn() {
        let newSpan = MKCoordinateSpan(
            latitudeDelta: max(region.span.latitudeDelta * 0.5, 0.05),
            longitudeDelta: max(region.span.longitudeDelta * 0.5, 0.05)
        )
        region.span = newSpan
    }
    
    func zoomOut() {
        let newSpan = MKCoordinateSpan(
            latitudeDelta: min(region.span.latitudeDelta * 2.0, 5.0),
            longitudeDelta: min(region.span.longitudeDelta * 2.0, 5.0)
        )
        region.span = newSpan
    }
    
    var estimatedTimeRemaining: String {
        guard isSimulating, let startTime = startTime else { return "Duración: 15 seg" }
        let elapsed = Date().timeIntervalSince(startTime)
        let remaining = max(simulationDuration - elapsed, 0)
        let seconds = Int(remaining)
        return "Faltan \(seconds) seg"
    }
}
