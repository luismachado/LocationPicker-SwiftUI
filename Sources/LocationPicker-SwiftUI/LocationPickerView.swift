//
//  LocationPickerView.swift
//  CustomLocationPickerSwiftUI
//
//  Created by Luís Machado on 24/06/2024.
//

import SwiftUI
import MapKit
import Contacts

@available(iOS 16.4, *)
public struct LocationPickerView<ViewModel: LocationPickerViewModel>: View {
    @Environment(\.dismissSearch) private var dismissSearch
    @Environment(\.dismiss) var dismiss

    @ObservedObject var viewModel: ViewModel

    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    @State private var showingBottomSheet: Bool = true

    public var body: some View {
        MapView(
            centerCoordinate: $viewModel.currentSelectedCoordinates,
            locationSelectedCallback: viewModel.locationSelectedOnMap
        )
            .ignoresSafeArea()
            .sheet(isPresented: $showingBottomSheet) {
                VStack {
                    searchSheetView
                }
                .headerProminence(.increased)
                .presentationDetents(
                    LocationPicker.DetentSizes.presentationDetentList,
                    selection: $viewModel.sheetPresentationDetent
                )
                .presentationBackgroundInteraction(.enabled(upThrough: .medium))
                .interactiveDismissDisabled()
            }
    }

    private var searchSheetView: some View {
        NavigationStack {
            VStack {
                searchContentView
            }
            .searchable(text: $viewModel.searchText)
            .onSubmit(of: .search, viewModel.performSearch)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Select") {
                        viewModel.doneTapped()
                    }
                    .disabled(!viewModel.doneEnabled)
                }
            }
        }
    }

    @ViewBuilder
    var searchContentView: some View {
        if viewModel.locations.isEmpty {
            Text("Search for a location or select on the map")
                .foregroundColor(.secondary)
                .font(.subheadline)
                .padding()
        } else {
            List {
                Section(
                    header: Text("Locations")
                        .font(.subheadline.smallCaps())
                        .foregroundColor(.secondary)
                ) {
                    ForEach(viewModel.locations, id: \.self) { location in
                        LocationRowView(placemark: location) {
                            viewModel.locationSelectedOnResults(location: location)
                        }
                    }
                }
            }
        }
    }
}

private struct LocationRowView: View {
    @Environment(\.dismissSearch) private var dismissSearch
    var placemark: CLPlacemark
    var onTap: () -> Void

    var body: some View {
        Button(action: {
            onTap()
            dismissSearch()
        }) {
            VStack(alignment: .leading, spacing: 3) {
                Text(placemark.name ?? "")
                    .foregroundColor(.primary)
                    .font(.headline)

                Text(
                    LocationHelpers.formattedAddress(
                        placemarker: placemark,
                        style: .mailingAddress
                    ) ?? ""
                )
                .foregroundColor(.secondary)
                .font(.subheadline)
            }
        }
    }
}




