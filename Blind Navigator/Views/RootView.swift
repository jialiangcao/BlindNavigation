//
//  RootView.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 6/3/25.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var navViewModel: NavigationViewModel

    var body: some View {
        switch navViewModel.currentScreen {
        case .auth:
            AuthView()
        case .startSession:
            StartSessionView(startSession: {
                navViewModel.startSession()
            })
        case .activeSession:
            StopwatchView()
            ActiveSessionView(
                sessionViewModel: SessionViewModel(),
                endSession: {
                    navViewModel.endSession()
                })
        }
    }
}
