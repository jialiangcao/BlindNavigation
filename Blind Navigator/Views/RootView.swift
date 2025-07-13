//
//  RootView.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 6/3/25.
//

import SwiftUI
import MetaWear
import MetaWearSync

struct RootView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var navViewModel: NavigationViewModel
    @EnvironmentObject var metaWearViewModel: MetaWearViewModel
    
    var body: some View {
        VStack {
            switch navViewModel.currentScreen {
            case .auth:
                AuthView()
            case .startSession:
                StartSessionView()
            case .activeSession:
                ActiveSessionView(sessionViewModel: SessionViewModel(metaWearViewModel: metaWearViewModel))
                .overlay(
                    StopwatchView()
                        .padding(), alignment: .top
                )
            case .deviceList:
                DeviceListView(metaWearViewModel: metaWearViewModel)
            }
        }
        .onAppear {
            if authViewModel.user != nil {
                navViewModel.currentScreen = .startSession
            } else {
                navViewModel.currentScreen = .auth
            }
        }
    }
}
