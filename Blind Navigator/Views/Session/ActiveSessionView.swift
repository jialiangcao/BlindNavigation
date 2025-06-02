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
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // MARK: - Map Tab
            Map(position: $cameraPosition, interactionModes: .all) {
                UserAnnotation()
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
            .tabItem {
                Label("Map", systemImage: "map.fill")
            }
            .tag(0)
            
            // MARK: - Session Tab
            VStack(spacing: 0) {
                ScrollView {
                    Text("Session Details")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.vertical, 24)
                        .frame(maxWidth: .infinity)
                        .shadow(color: Color.black.opacity(0.05), radius: 3, y: 2)

                    VStack(alignment: .leading, spacing: 16) {
                        Text("STATISTICS")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                        
                        StatisticCard(
                            title: "Prediction",
                            value: sessionViewModel.prediction ?? "Disabled",
                            icon: "waveform.path.ecg"
                        )
                        
                        StatisticCard(
                            title: "Decibels",
                            // Syntax necessary to avoid type inference error
                            value: sessionViewModel.decibelLevel.map { "\($0)"} ?? "Disabled",
                            icon: "speaker.wave.2.fill"
                        )
                        
                        StatisticCard(
                            title: "GPS Accuracy",
                            value: "\(sessionViewModel.locationAccuracy ?? 0) meters",
                            icon: "location.fill"
                        )
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.secondarySystemBackground))
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // End Session Button
                    Button(action: endSession) {
                        Text("End Session")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.red)
                            )
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                    .buttonStyle(ScaleButtonStyle())
                }
                .background(Color(.systemGroupedBackground))
            }
            .tabItem {
                Label("Session", systemImage: "gearshape.fill")
            }
            .tag(1)
        }
        .tint(.cyan)
        .onAppear {
            // Customize tab bar appearance for iOS 15+
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}


#Preview {
    StopwatchView()
    ActiveSessionView(sessionViewModel: SessionViewModel(), endSession: {})
}
