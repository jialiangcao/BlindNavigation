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
    @StateObject private var sessionManager = SessionManager()
   
    var body: some Scene {
        WindowGroup {
            if authStore.user == nil {
                LoginPage()
            } else {
                if sessionManager.isSessionActive {
                    ActiveSessionView(sessionManager: sessionManager)
                } else {
                    StartSessionView(sessionManager: sessionManager)
                }
            }
        }
    }
}
