//
//  ActiveSessionView.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 4/26/25.
//
import SwiftUI
import MapKit

struct ActiveSessionView: View {
    @ObservedObject var sessionManager: SessionManager
    
    var body: some View {
        TabView {
            Tab("Maps", systemImage: "map.fill") {
                Map {}
            }
            Tab("Predictions", systemImage: "waveform.path") {
                Text("Prediction: Accuracy:")
            }
        }
    }
}

#Preview {
    ActiveSessionView(sessionManager: SessionManager())
}
