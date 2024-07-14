import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @Binding var locationCoordinate: CLLocationCoordinate2D
    @Binding var region: MKCoordinateRegion

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        let gestureRecognizer = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.addAnnotation(gestureRecognizer:)))
        mapView.addGestureRecognizer(gestureRecognizer)
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationCoordinate
        uiView.removeAnnotations(uiView.annotations)
        uiView.addAnnotation(annotation)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        @objc func addAnnotation(gestureRecognizer: UILongPressGestureRecognizer) {
            if gestureRecognizer.state == .began {
                let location = gestureRecognizer.location(in: gestureRecognizer.view)
                let coordinate = (gestureRecognizer.view as! MKMapView).convert(location, toCoordinateFrom: gestureRecognizer.view)
                parent.locationCoordinate = coordinate
                parent.region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
            }
        }
    }
}
