//
//  ContentView.swift
//  DemoApp
//
//  Created by Luís Machado on 25/06/2024.
//

import SwiftUI
import MapKit
import LocationPicker_SwiftUI

struct ContentView: View {
    @State private var viewModel: LocationPicker? = nil
    @State private var selectedLocation: CLPlacemark?

    var body: some View {
        VStack {
            Button("Show Map") {
                viewModel = LocationPicker(initialLocation: selectedLocation, onReturn: onReturn)
            }

            if let selectedLocation {
                Text("Selected Location:")
                Text(selectedLocation.name ?? "")
            }

        }
        .sheet(item: $viewModel) { viewModel in
            LocationPickerView(viewModel: viewModel)
        }
    }

    func onReturn(_ location: CLPlacemark?) {
        selectedLocation = location
        viewModel = nil
    }
}

#Preview {
    ContentView()
}
