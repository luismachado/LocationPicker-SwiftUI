//
//  LocationHelpers.swift
//  CustomLocationPickerSwiftUI
//
//  Created by Luís Machado on 24/06/2024.
//

import MapKit
import Contacts

class LocationHelpers {
    /// Search for a placemark based on a set of coordinates
    static func reverseGeocoding(coordinates: CLLocationCoordinate2D) async -> CLPlacemark? {
        let geocoder = CLGeocoder()

        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(
                .init(
                    latitude: coordinates.latitude,
                    longitude: coordinates.longitude
                )
            )
            return placemarks.first
        } catch {
            return nil
        }
    }

    /// Search for a - set of - placemark(s) based on a text prompt
    static func geocoding(text: String) async -> [MKPlacemark] {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = text
        let search = MKLocalSearch(request: searchRequest)

        do {
            let result = try await search.start()
            return Array(result.mapItems.map { $0.placemark }.prefix(3))
        } catch {
            return []
        }
    }

    /// Readable address - with custom styling - for a specific placemark
    static func formattedAddress(
        placemarker: CLPlacemark,
        style: CNPostalAddressFormatterStyle? = nil
    ) -> String? {
        guard let postalAddress = placemarker.postalAddress else {
            return nil
        }

        if let style {
            return CNPostalAddressFormatter.string(from: postalAddress, style: style)
        }
        
        return CNPostalAddressFormatter().string(from: postalAddress)
    }
}
