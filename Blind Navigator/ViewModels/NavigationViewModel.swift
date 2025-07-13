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
    case deviceList
    case preSessionView
}

final class NavigationViewModel: ObservableObject {
    @Published var currentScreen: AppScreen = .auth
    
    func setActiveSessionView() {
        currentScreen = .activeSession
    }
    
    func setStartSessionView() {
        currentScreen = .startSession
    }

    func setAuthView() {
        currentScreen = .auth
    }
    
    func setDeviceListView() {
        currentScreen = .deviceList
    }
    
    func setPreSessionView() {
        currentScreen = .preSessionView
    }
}
