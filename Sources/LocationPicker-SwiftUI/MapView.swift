//
//  MapView.swift
//  CustomLocationPickerSwiftUI
//
//  Created by Luís Machado on 21/06/2024.
//

import Foundation
import SwiftUI
import MapKit
import CoreLocation

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

struct MapView: UIViewRepresentable {
    @Binding var centerCoordinate: CLLocationCoordinate2D?
    var locationSelectedCallback: (CLLocationCoordinate2D) -> Void

    var zoomLevel: Double?

    let mapView = MKMapView()

    func makeUIView(context: Context) -> MKMapView {
        mapView.delegate = context.coordinator

        return mapView
    }

    private func setAnnotation(view: MKMapView) {
        guard let centerCoordinate = centerCoordinate else { return }

        // If the annotation didn't change we can return
        if view.annotations.first?.coordinate == centerCoordinate { return }

        // Place the pin on the map and update region
        let annotation = MKPointAnnotation()
        annotation.coordinate = centerCoordinate

        withAnimation {
            view.removeAnnotations(view.annotations)
            view.addAnnotation(annotation)
            view.setRegion(
                .init(
                    center: annotation.coordinate,
                    latitudinalMeters: 2000,
                    longitudinalMeters: 2000
                ),
                animated: true
            )
        }
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        setAnnotation(view: view)
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate, UIGestureRecognizerDelegate {
        var parent: MapView

        var gestureRecognizer = UILongPressGestureRecognizer()

        init(_ parent: MapView) {
            self.parent = parent
            super.init()

            self.gestureRecognizer = UILongPressGestureRecognizer(target: self, action:#selector(self.handleLongPress))
            self.gestureRecognizer.delegate = self
            self.parent.mapView.addGestureRecognizer(gestureRecognizer)
        }

        @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
            if gestureRecognizer.state == UIGestureRecognizer.State.began {
                let location = gestureRecognizer.location(in: self.parent.mapView)
                let coordinate = self.parent.mapView.convert(location, toCoordinateFrom: self.parent.mapView)

                // Set the selected coordinates
                let clObject = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)

                parent.locationSelectedCallback(clObject)
                parent.centerCoordinate = clObject
            } else {
                return
            }
        }
    }
}
