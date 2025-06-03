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
    case history
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
    
    func showHistory() {
        currentScreen = .history
    }
}
