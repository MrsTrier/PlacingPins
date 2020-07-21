//
//  MapView.swift
//  TestMapProj
//
//  Created by Cheremushka on 11.07.2020.
//  Copyright © 2020 Daria Cheremina. All rights reserved.
//


import MapKit
import CoreLocation
import SwiftUI

struct MapView: UIViewRepresentable {
    
    let mapView = MKMapView()
    var annotations : [MKPointAnnotation]
    @Binding var removeAnnotations : [MKPointAnnotation]
    @Binding var selectedPlace: MKPointAnnotation?
    @Binding var centerCoordinate: CLLocationCoordinate2D
    @Binding var pastCenterCoordinate: CLLocationCoordinate2D
    @Binding var showingPlaceDetails: Bool
    @Binding var allAnotations: Bool

    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate, CLLocationManagerDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
            super.init()
        }
        
        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            parent.centerCoordinate = mapView.centerCoordinate
        }
        
        func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
            if let annotationView = views.first {
                if let annotation = annotationView.annotation {
                    if annotation is MKUserLocation {
                        
                        let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 19000, longitudinalMeters: 19000)
                        mapView.setRegion(region, animated: true)
                    }
                }
            }
        }
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
                guard let placemark = view.annotation as? MKPointAnnotation else { return }
                parent.selectedPlace = placemark
                parent.showingPlaceDetails = true
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let identifier = "Placemark"

            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)

                annotationView?.canShowCallout = true

                annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            } else {
                annotationView?.annotation = annotation
            }

            return annotationView
        }
    }
    
    func makeUIView(context: UIViewRepresentableContext<MapView>) -> MKMapView {
        mapView.showsUserLocation = true
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapView>) {
        uiView.removeAnnotations(removeAnnotations)
        uiView.addAnnotations(annotations)
    }
}

extension MKPointAnnotation {
    static var example: MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.title = "London"
        annotation.subtitle = "Home to the 2012 Summer Olympics."
        annotation.coordinate = CLLocationCoordinate2D(latitude: 51.5, longitude: -0.13)
        return annotation
    }
}
