import SwiftUI
import MapKit

struct MapViewContainer: UIViewRepresentable {
    @ObservedObject var viewModel: TripSimulationViewModel
    @Binding var region: MKCoordinateRegion
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = false
        mapView.mapType = .standard
        mapView.showsCompass = true
        mapView.showsScale = true
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.setRegion(region, animated: true)
        
        mapView.removeAnnotations(mapView.annotations)
        
        for annotation in viewModel.mapAnnotations {
            mapView.addAnnotation(annotation)
        }
        
        mapView.removeOverlays(mapView.overlays)
        
        if !viewModel.routeCoordinates.isEmpty {
            let fullRoute = MKPolyline(coordinates: viewModel.routeCoordinates, count: viewModel.routeCoordinates.count)
            fullRoute.title = "full"
            mapView.addOverlay(fullRoute)
            
            if viewModel.progress > 0 {
                let progressIndex = Int(Double(viewModel.routeCoordinates.count) * viewModel.progress)
                let visibleCoordinates = Array(viewModel.routeCoordinates.prefix(progressIndex))
                
                if visibleCoordinates.count > 1 {
                    let completedRoute = MKPolyline(coordinates: visibleCoordinates, count: visibleCoordinates.count)
                    completedRoute.title = "completed"
                    mapView.addOverlay(completedRoute)
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewContainer
        
        init(_ parent: MapViewContainer) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let customAnnotation = annotation as? CustomAnnotation else { return nil }
            
            let identifier = customAnnotation.type.rawValue
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = false
            } else {
                annotationView?.annotation = annotation
            }
            
            switch customAnnotation.type {
            case .origin:
                annotationView?.image = createVehicleImage()
            case .destination:
                annotationView?.image = createDestinationImage()
            case .vehicle:
                annotationView?.image = createVehicleImage()
                annotationView?.layer.zPosition = 1000
            }
            
            annotationView?.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            return annotationView
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                
                if polyline.title == "completed" {
                    renderer.strokeColor = UIColor.systemBlue
                    renderer.lineWidth = 5
                } else {
                    renderer.strokeColor = UIColor.systemOrange.withAlphaComponent(0.7)
                    renderer.lineWidth = 4
                    renderer.lineDashPattern = [8, 6]
                }
                
                renderer.lineCap = .round
                renderer.lineJoin = .round
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
        
        private func createVehicleImage() -> UIImage {
            let size = CGSize(width: 80, height: 80)
            let renderer = UIGraphicsImageRenderer(size: size)
            return renderer.image { context in
                context.cgContext.setShadow(offset: CGSize(width: 0, height: 4), blur: 10, color: UIColor.black.withAlphaComponent(0.5).cgColor)
                
                let outerCircle = UIBezierPath(ovalIn: CGRect(x: 10, y: 10, width: 60, height: 60))
                UIColor.systemBlue.setFill()
                outerCircle.fill()
                
                let whiteBorder = UIBezierPath(ovalIn: CGRect(x: 14, y: 14, width: 52, height: 52))
                UIColor.white.setStroke()
                whiteBorder.lineWidth = 4
                whiteBorder.stroke()
                
                let innerCircle = UIBezierPath(ovalIn: CGRect(x: 18, y: 18, width: 44, height: 44))
                UIColor.white.setFill()
                innerCircle.fill()
                
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 36, weight: .bold),
                    .foregroundColor: UIColor.systemBlue
                ]
                let string = "🚐" as NSString
                let textSize = string.size(withAttributes: attrs)
                let point = CGPoint(x: (size.width - textSize.width) / 2, y: (size.height - textSize.height) / 2)
                string.draw(at: point, withAttributes: attrs)
            }
        }
        
        private func createDestinationImage() -> UIImage {
            let size = CGSize(width: 80, height: 80)
            let renderer = UIGraphicsImageRenderer(size: size)
            return renderer.image { context in
                context.cgContext.setShadow(offset: CGSize(width: 0, height: 4), blur: 10, color: UIColor.black.withAlphaComponent(0.5).cgColor)
                
                let outerCircle = UIBezierPath(ovalIn: CGRect(x: 10, y: 10, width: 60, height: 60))
                UIColor.systemRed.setFill()
                outerCircle.fill()
                
                let whiteBorder = UIBezierPath(ovalIn: CGRect(x: 14, y: 14, width: 52, height: 52))
                UIColor.white.setStroke()
                whiteBorder.lineWidth = 4
                whiteBorder.stroke()
                
                let innerCircle = UIBezierPath(ovalIn: CGRect(x: 18, y: 18, width: 44, height: 44))
                UIColor.white.setFill()
                innerCircle.fill()
                
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 36, weight: .bold),
                    .foregroundColor: UIColor.systemRed
                ]
                let string = "🏁" as NSString
                let textSize = string.size(withAttributes: attrs)
                let point = CGPoint(x: (size.width - textSize.width) / 2, y: (size.height - textSize.height) / 2)
                string.draw(at: point, withAttributes: attrs)
            }
        }
    }
}

class CustomAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    let title: String?
    let type: AnnotationType
    
    enum AnnotationType: String {
        case origin
        case destination
        case vehicle
    }
    
    init(coordinate: CLLocationCoordinate2D, title: String?, type: AnnotationType) {
        self.coordinate = coordinate
        self.title = title
        self.type = type
        super.init()
    }
}
