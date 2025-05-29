//
//  ActiveSessionView.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 4/26/25.
//
import SwiftUI
import MapKit

struct ActiveSessionView: View {
    @ObservedObject var sessionViewModel: SessionViewModel
    let endSession: () -> Void
    
    @State private var cameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060), // Default to NYC
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        )
    )
    
    var body: some View {
        TabView {
            Tab("Maps", systemImage: "map.fill") {
                Map(position: $cameraPosition, interactionModes: .all) {
                    UserAnnotation()
                }
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
            Tab("Predictions", systemImage: "waveform.path") {
                Text("Prediction: Accuracy:")
            }
        }
    }
}

#Preview {
    ActiveSessionView(sessionViewModel: SessionViewModel(), endSession: {})
}
