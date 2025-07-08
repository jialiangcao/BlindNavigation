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
        ZStack {
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

            ZStack {
                if sessionViewModel.isMetaWearConnected == false {
                    BannerNotificationView(
                        systemImageName: "exclamationmark.triangle.fill",
                        message: "MetaWear not connected. Data will not be saved.",
                        backgroundColor: .red
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                if let error = sessionViewModel.recordingError {
                    BannerNotificationView(
                        systemImageName: "exclamationmark.triangle.fill",
                        message: error,
                        backgroundColor: .yellow
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .animation(.easeInOut, value: sessionViewModel.recordingError)
            .animation(.easeInOut, value: sessionViewModel.isMetaWearConnected)
        }
        .onAppear {
            Task {
                await sessionViewModel.startCameraService()
                sessionViewModel.startRecording()
            }
        }
    }
}

#Preview {
    ActiveSessionView(sessionViewModel: SessionViewModel(metaWearViewModel: MetaWearViewModel()))
        .environmentObject(NavigationViewModel())
}
