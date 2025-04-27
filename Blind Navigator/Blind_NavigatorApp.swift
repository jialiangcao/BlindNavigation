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
    // Will automatically re-evaluate if state is changed
    @StateObject private var session = SessionStore()
   
    var body: some Scene {
        WindowGroup {
            if session.user == nil {
              // No user is signed in
                LoginPage()
            } else {
                MapPage()
            }
        }
    }
}
