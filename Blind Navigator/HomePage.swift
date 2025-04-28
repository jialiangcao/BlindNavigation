//
//  MapPage.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 4/26/25.
//
import SwiftUI
import FirebaseAuth

struct HomePage: View {
    @State private var isMapViewActive = false
    
    private func signOut() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Button(action: signOut) {
                    Text("Sign Out")
                }
                TabView {
                    Text("Hello world")
                }
            }
            .gesture(DragGesture().onEnded { value in
                if value.translation.width < -100 {
                    self.isMapViewActive = true
                }
            })
            .background(NavigationLink(
                destination: MapView(),
                isActive: $isMapViewActive,
                label: { EmptyView() }
            )
            )
        }
    }
}

#Preview {
    HomePage()
}
