//
//  MapView.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 6/11/25.
//

import SwiftUI
import MapKit

struct MapView: View {
    @ObservedObject var sessionViewModel: SessionViewModel
    @State private var cameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060), // Default to NYC
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        )
    )
    
    var body: some View {
        Map(position: $cameraPosition, interactionModes: .all) {
            UserAnnotation()
            MapPolyline(coordinates: sessionViewModel.userPath)
                .stroke(Color.mint, lineWidth: 4)
        }
        .mapStyle(.standard(elevation: .realistic))
        .mapControlVisibility(.hidden)
        .onReceive(sessionViewModel.$userLocation) { location in
            if let loc = location {
                let region = MKCoordinateRegion(
                    center: loc,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
                cameraPosition = .region(region)
            }
        }
    }
}

#Preview {
    MapView(sessionViewModel: SessionViewModel())
}
