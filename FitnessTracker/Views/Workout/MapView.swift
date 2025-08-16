//
//  MapView.swift
//  FitnessTracker
//
//  Created by Rishi Dave on 8/16/25.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @Binding var isWorkoutActive: Bool
    let locationManager: LocationManager
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.userTrackingMode = .follow
        mapView.showsUserLocation = true
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        if isWorkoutActive {
            context.coordinator.updateRoute(mapView: mapView,
                                          locations: locationManager.locations)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func updateRoute(mapView: MKMapView, locations: [CLLocation]) {
            guard locations.count > 1 else { return }
            
            let coordinates = locations.map { $0.coordinate }
            let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
            
            mapView.removeOverlays(mapView.overlays)
            mapView.addOverlay(polyline)
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .systemBlue
                renderer.lineWidth = 4
                return renderer
            }
            return MKOverlayRenderer()
        }
    }
}
