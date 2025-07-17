//
//  ActiveSessionView.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 4/26/25.
//
import SwiftUI

struct ActiveSessionView: View {
    @ObservedObject var sessionViewModel: SessionViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .top) {
            if sessionViewModel.isMetaWearConnected == false && sessionViewModel.isEnding == false {
                NotificationPopup(
                    title: "The MetaWear sensor disconnected. We're trying to reconnect... try holding the phone closer to the bottom of the cane and wait 10-15 seconds. If the issue persists, end the session and create a new one, your data is saved.",
                    systemIconName: "exclamationmark.triangle.fill",
                    backgroundColor: .red
                )
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.easeInOut, value: sessionViewModel.isMetaWearConnected)
                .padding(.top, 80)
                .zIndex(1)
            }
            
            if let error = sessionViewModel.recordingError {
                NotificationPopup(
                    title: error,
                    systemIconName: "exclamationmark.triangle.fill",
                    backgroundColor: .yellow
                )
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.easeInOut, value: sessionViewModel.recordingError)
                .padding(.top, 80)
                .zIndex(1)
            }
            
            TabView(selection: $selectedTab) {
                CameraView(sessionViewModel: sessionViewModel)
                    .tabItem {
                        Label("Camera", systemImage: "camera.fill")
                    }
                    .tag(0)
                
                MapView(sessionViewModel: sessionViewModel)
                    .tabItem {
                        Label("Map", systemImage: "map.fill")
                    }
                    .tag(1)
                
                StatisticsView(sessionViewModel: sessionViewModel)
                    .tabItem {
                        Label("Session", systemImage: "gearshape.fill")
                    }
                    .tag(2)
            }
            .tint(.cyan)
            .onAppear {
                let appearance = UITabBarAppearance()
                appearance.configureWithDefaultBackground()
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
            .onAppear {
                Task {
                    await sessionViewModel.startCameraService()
                    
                    // Starting recording before preview is attached will break
                    while sessionViewModel.isPreviewAttached == false {
                        try? await Task.sleep(nanoseconds: 50_000_000)
                    }
                    
                    sessionViewModel.startRecording()
                }
            }
        }
    }
}

#Preview {
    ActiveSessionView(sessionViewModel: SessionViewModel(metaWearViewModel: MetaWearViewModel()))
        .environmentObject(NavigationViewModel())
}
