//
//  LocationPickerViewModel.swift
//  CustomLocationPickerSwiftUI
//
//  Created by Luís Machado on 24/06/2024.
//

import Foundation
import SwiftUI
import MapKit

public protocol LocationPickerViewModel: ObservableObject, Identifiable {
    var searchText: String { get set }
    var locations: [CLPlacemark] { get }
    var currentSelectedCoordinates: CLLocationCoordinate2D? { get set }
    var sheetPresentationDetent: PresentationDetent { get set }
    var doneEnabled: Bool { get }

    func performSearch()
    func locationSelectedOnMap(location: CLLocationCoordinate2D)
    func locationSelectedOnResults(location: CLPlacemark)
    func doneTapped()
}

public class LocationPicker: LocationPickerViewModel {
    public enum DetentSizes: CaseIterable {
        case small
        case medium
        case large

        var presentationDetent: PresentationDetent {
            switch self {
                case .small:
                    return .height(140)
                case .medium:
                    return .height(300)
                case .large:
                    return .medium
            }
        }

        static var presentationDetentList: Set<PresentationDetent> {
            Set(Self.allCases.map { $0.presentationDetent })
        }

        static func adequateIntent(resultSize: Int) -> PresentationDetent {
            if resultSize == 0 {
                return Self.small.presentationDetent
            } else if resultSize <= 2 {
                return Self.medium.presentationDetent
            } else {
                return Self.large.presentationDetent
            }
        }
    }

    @Published public var currentSelectedCoordinates: CLLocationCoordinate2D?
    @Published public var sheetPresentationDetent: PresentationDetent = DetentSizes.small.presentationDetent
    @Published public var searchText: String = ""
    @Published public var locations: [CLPlacemark] = []
    private var currentSelectedPlacemark: CLPlacemark?

    private var onReturn: (CLPlacemark?) -> Void

    public init(initialLocation: CLPlacemark? = nil, onReturn: @escaping (CLPlacemark?) -> Void) {
        self.onReturn = onReturn

        if let initialLocation {
            locationSelectedOnResults(location: initialLocation)
        }
    }

    public var doneEnabled: Bool {
        currentSelectedPlacemark != nil
    }

    public func locationSelectedOnMap(location: CLLocationCoordinate2D) {
        Task {
            let location = await LocationHelpers.reverseGeocoding(coordinates: location)
            currentSelectedPlacemark = location
            updateLocations([location].compactMap { $0 })
        }
    }

    public func locationSelectedOnResults(location: CLPlacemark) {
        currentSelectedPlacemark = location
        currentSelectedCoordinates = location.location?.coordinate
    }

    private func updateLocations(_ locations: [CLPlacemark]) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }

            strongSelf.locations.removeAll()
            strongSelf.locations.append(contentsOf: locations)
            strongSelf.sheetPresentationDetent = DetentSizes.adequateIntent(
                resultSize: locations.count
            )
        }
    }

    public func performSearch() {
        guard !searchText.isEmpty else {
            updateLocations([])
            return
        }

        Task {
            let locations = await LocationHelpers.geocoding(text: searchText)
            updateLocations(locations)
        }
    }
    
    public func doneTapped() {
        onReturn(currentSelectedPlacemark)
    }
}
