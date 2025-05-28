//
//  SessionManager.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 5/28/25.
//

import Foundation

final class SessionManager: ObservableObject {
    @Published var isSessionActive = false
    
    func startSession() {}
    func stopSession() {}
}
