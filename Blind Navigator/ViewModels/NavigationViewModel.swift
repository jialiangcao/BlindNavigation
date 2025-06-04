//
//  NavigationViewModel.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 6/3/25.
//

import Foundation
import Combine

enum AppScreen {
    case auth
    case startSession
    case activeSession
}
class NavigationViewModel: ObservableObject {
    @Published var currentScreen: AppScreen = .auth
    
    func startSession() {
        currentScreen = .activeSession
    }
    
    func endSession() {
        currentScreen = .startSession
    }

    func signedIn() {
        currentScreen = .startSession
    }

    func signedOut() {
        currentScreen = .auth
    }
}
