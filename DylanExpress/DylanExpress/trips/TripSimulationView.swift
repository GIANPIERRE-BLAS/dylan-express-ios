import SwiftUI
import MapKit

struct TripSimulationView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @Environment(\.presentationMode) var presentationMode
    
    let booking: BookingData
    
    @StateObject private var viewModel: TripSimulationViewModel
    @State private var navigateToRating = false
    
    init(booking: BookingData) {
        self.booking = booking
        _viewModel = StateObject(wrappedValue: TripSimulationViewModel(booking: booking))
    }
    
    var body: some View {
        ZStack {
            NavigationLink(
                destination: RatingView(booking: booking),
                isActive: $navigateToRating
            ) {
                EmptyView()
            }
            
            MapViewContainer(
                viewModel: viewModel,
                region: $viewModel.region
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                routeInfoFloating
                
                Spacer()
                    .frame(height: 20)
                
                tripInfoHeader
                
                Spacer()
                
                if !viewModel.hasCompleted {
                    controlPanel
                } else {
                    completedPanel
                }
            }
            
            if viewModel.isSimulating || viewModel.progress > 0 {
                if !viewModel.hasCompleted {
                    mapControls
                }
            }
        }
        .navigationBarTitle("Mis Viajes", displayMode: .inline)
        .onAppear {
            viewModel.setupRoute()
            viewModel.centerOnRoute()
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
    
    private var mapControls: some View {
        VStack {
            Spacer()
            
            HStack {
                VStack(spacing: 12) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.zoomIn()
                        }
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Color.black.opacity(0.7)))
                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.zoomOut()
                        }
                    }) {
                        Image(systemName: "minus")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Color.black.opacity(0.7)))
                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                }
                .padding(.leading, 16)
                .padding(.bottom, 100)
                
                Spacer()
                
                VStack(spacing: 12) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            viewModel.centerOnRoute()
                        }
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: "map.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                            Text("Ruta")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .frame(width: 60, height: 60)
                        .background(LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    
                    if viewModel.isSimulating {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                viewModel.followVehicle()
                            }
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.white)
                                Text("Combi")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .frame(width: 60, height: 60)
                            .background(LinearGradient(gradient: Gradient(colors: [.green, Color(red: 0.0, green: 0.6, blue: 0.3)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                    }
                }
                .padding(.trailing, 16)
                .padding(.bottom, 100)
            }
        }
    }
    
    private var routeInfoFloating: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Text(viewModel.totalDistance)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("/")
                    .font(.system(size: 20, weight: .light))
                    .foregroundColor(.white.opacity(0.7))
                
                Text(viewModel.totalDurationText)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.15))
                    
                    RoundedRectangle(cornerRadius: 20)
                        .fill(LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.25), Color.white.opacity(0.05)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                }
                .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 8)
            )
            .background(RoundedRectangle(cornerRadius: 20).fill(.ultraThinMaterial))
            
            Text(booking.origin + " → " + booking.destination)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    ZStack {
                        Capsule().fill(Color.white.opacity(0.15))
                        Capsule().fill(LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.2), Color.white.opacity(0.05)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        Capsule().stroke(Color.white.opacity(0.25), lineWidth: 1)
                    }
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                )
                .background(Capsule().fill(.ultraThinMaterial))
        }
        .padding(.top, 8)
    }
    
    private var tripInfoHeader: some View {
        VStack(spacing: 12) {
            if viewModel.isSimulating {
                VStack(spacing: 8) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                            .scaleEffect(viewModel.pulseScale)
                            .animation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: viewModel.pulseScale)
                        Text("Tu combi está en camino")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    
                    HStack(spacing: 12) {
                        HStack(spacing: 6) {
                            Image(systemName: "clock.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                            Text(viewModel.estimatedArrival)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(isDarkMode ? .white : .black)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(12)
                        
                        HStack(spacing: 6) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.caption)
                                .foregroundColor(.blue)
                            Text(viewModel.distanceRemaining)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(isDarkMode ? .white : .black)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(12)
                    }
                }
                .padding(.bottom, 8)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.isSimulating ? "Origen" : "Listo para iniciar")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .fontWeight(.semibold)
                    Text(booking.origin)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(isDarkMode ? .white : .black)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Destino")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(booking.destination)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(isDarkMode ? .white : .black)
                }
            }
            
            if viewModel.isSimulating {
                VStack(spacing: 8) {
                    HStack {
                        Text("\(Int(viewModel.progress * 100))% del recorrido")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                        Spacer()
                        Text(viewModel.estimatedTimeRemaining)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .fontWeight(.medium)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(LinearGradient(gradient: Gradient(colors: [.blue, .green]), startPoint: .leading, endPoint: .trailing))
                                .frame(width: geometry.size.width * CGFloat(viewModel.progress), height: 8)
                                .animation(.linear(duration: 0.3))
                        }
                    }
                    .frame(height: 8)
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 20).fill(isDarkMode ? Color.black.opacity(0.9) : Color.white).shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 5))
        .padding(.horizontal)
        .padding(.top)
    }
    
    private var controlPanel: some View {
        VStack(spacing: 0) {
            if !viewModel.isSimulating && viewModel.progress == 0 {
                Button(action: {
                    viewModel.startSimulation()
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 24))
                        Text("Iniciar Viaje")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(startTripGradient)
                    .cornerRadius(16)
                    .shadow(color: .cyan.opacity(0.4), radius: 10, x: 0, y: 5)
                }
                .padding()
            } else if viewModel.isSimulating {
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .stroke(Color.blue.opacity(0.3), lineWidth: 3)
                                .frame(width: 40, height: 40)
                            
                            Circle()
                                .trim(from: 0, to: 0.7)
                                .stroke(Color.blue, lineWidth: 3)
                                .frame(width: 40, height: 40)
                                .rotationEffect(.degrees(viewModel.spinnerRotation))
                                .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: viewModel.spinnerRotation)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Viaje en curso")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(isDarkMode ? .white : .black)
                            Text("Sigue tu recorrido en el mapa")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                    .padding()
                }
                .background(RoundedRectangle(cornerRadius: 20).fill(isDarkMode ? Color.black.opacity(0.9) : Color.white).shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: -5))
            }
        }
    }
    
    private var completedPanel: some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                    .scaleEffect(viewModel.completionScale)
                    .animation(.spring(response: 0.6, dampingFraction: 0.5), value: viewModel.completionScale)
                
                Text("¡Llegaste a tu destino!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(isDarkMode ? .white : .black)
                
                Text(booking.destination)
                    .font(.headline)
                    .foregroundColor(.gray)
            }
            .padding(.top)
            
            Button(action: {
                navigateToRating = true
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 22))
                    Text("Calificar Viaje")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(LinearGradient(gradient: Gradient(colors: [.green, Color(red: 0.0, green: 0.6, blue: 0.3)]), startPoint: .leading, endPoint: .trailing))
                .cornerRadius(16)
                .shadow(color: .green.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            
            Button(action: {
                viewModel.resetSimulation()
            }) {
                Text("Ver recorrido de nuevo")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    .padding(.vertical, 12)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 20).fill(isDarkMode ? Color.black.opacity(0.9) : Color.white).shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: -5))
        .padding(.horizontal)
        .padding(.bottom)
    }
}
