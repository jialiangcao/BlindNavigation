//
//  Blind_NavigatorApp.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 4/26/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

@main
struct Blind_NavigatorApp: App {
    // Firebase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authStore = AuthStore()
    @State private var isSessionActive = false
   
    var body: some Scene {
        WindowGroup {
            if authStore.user == nil {
                LoginPage()
            } else {
                // Passes in function closures to trigger session state within a child view
                if isSessionActive {
                    ActiveSessionView(sessionManager: SessionManager(),
                                      endSession: { isSessionActive = false }
                    )
                } else {
                    StartSessionView(startSession: {
                        isSessionActive = true
                    })
                }
            }
        }
    }
}
