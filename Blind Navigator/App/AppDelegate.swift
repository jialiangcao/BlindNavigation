//
//  AppDelegate.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 4/26/25.
//
// Delegate to handle app lifecycle events
//  - Initializes Firebase
//  - Conforms to NSObject for Objective-C compatability
//  - UIKit Style

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    // Configures Firebase AFTER app has finished launching
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}


