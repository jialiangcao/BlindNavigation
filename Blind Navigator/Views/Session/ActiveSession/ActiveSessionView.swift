//
//  ActiveSessionView.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 4/26/25.
//
import SwiftUI

struct ActiveSessionView: View {
    @ObservedObject var sessionViewModel: SessionViewModel
    let endSession: () -> Void
    
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MapView(sessionViewModel: sessionViewModel)
            .tabItem {
                Label("Map", systemImage: "map.fill")
            }
            .tag(0)
            
            CameraView(sessionViewModel: sessionViewModel)
            .tabItem {
                Label("Camera", systemImage: "camera.fill")
            }
            .tag(1)
            
            StatisticsView(sessionViewModel: sessionViewModel, endSession: endSession)
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
    }
}

#Preview {
    ActiveSessionView(sessionViewModel: SessionViewModel(metaWearViewModel: MetaWearViewModel()), endSession: {})
}
