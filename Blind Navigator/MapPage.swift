//
//  MapPage.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 4/26/25.
//
import SwiftUI
import FirebaseAuth

struct MapPage: View {
    private func signOut() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
    }
    
    var body: some View {
        Text("Hello world")
        Button(action: signOut) {
            Text("Sign Out")
        }
    }
}

#Preview {
    MapPage()
}
