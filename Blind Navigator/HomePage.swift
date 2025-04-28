//
//  MapPage.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 4/26/25.
//
import SwiftUI
import FirebaseAuth

struct HomePage: View {
    private func signOut() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
    }
    
    var body: some View {
        TabView {
            Tab("Predictions", systemImage: "waveform.path") {
                Text("Hello world")
                Button(action: signOut) {
                    Text("Sign Out")
                }
            }
            Tab("Maps", systemImage: "map.fill") {
                MapView()
            }
        }
    }
}

#Preview {
    HomePage()
}
