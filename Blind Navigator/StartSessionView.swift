//
//  StartSessionView.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 5/28/25.
//
import SwiftUI
import FirebaseAuth

struct StartSessionView: View {
    let startSession: () -> Void
    
    private func signOut() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
    }
    
    var body: some View {
        Text("Ready to start a new session?")
        Button("Start Session", action: startSession)
        
        Button(action: signOut) {
            Text("Sign Out")
        }
    }
}

#Preview {
    StartSessionView(startSession: {})
}
