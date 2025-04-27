//
//  Blind_NavigatorApp.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 4/26/25.
//

import SwiftUI

@main
struct Blind_NavigatorApp: App {
    @State private var signedIn = false
    
    var body: some Scene {
        WindowGroup {
            if (!signedIn) {
                LoginPage()
            } else {
                MapPage()
            }
        }
    }
}
