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
    @StateObject private var authViewModel = AuthViewModel()
    
    @State var isSessionActive = false
   
    var body: some Scene {
        WindowGroup {
            if authViewModel.user == nil {
                AuthView()
                    .environmentObject(authViewModel)
            } else {
                // Passes in function closures to trigger session state within a child view
                if isSessionActive {
                    StopwatchView()
                    ActiveSessionView(sessionViewModel: SessionViewModel(),
                    endSession: {
                        isSessionActive = false
                    })
                } else {
                    StartSessionView(
                    startSession: {
                        isSessionActive = true
                    })
                }
            }
        }
    }
}
