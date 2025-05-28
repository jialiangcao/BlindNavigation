//
//  AuthStore.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 4/26/25.
//
// Handles Signed In/Out user-state
//

import SwiftUI
import FirebaseAuth

final class AuthStore: ObservableObject {
    // Observable, will trigger changes in listeners
    @Published var user: FirebaseAuth.User?
    private var authHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        authHandle = Auth.auth().addStateDidChangeListener { _, user in
            self.user = user
        }
    }
    
    // Will deinit and remove authHandle from history when no longer being observed
    deinit {
        if let handle = authHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
