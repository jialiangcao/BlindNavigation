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
    @StateObject private var navigationViewModel = NavigationViewModel()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authViewModel)
                .environmentObject(navigationViewModel)
        }
    }
}
