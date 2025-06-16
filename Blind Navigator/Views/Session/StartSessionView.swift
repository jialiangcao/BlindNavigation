//
//  StartSessionView.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 5/28/25.
//
import SwiftUI
import FirebaseAuth

struct StartSessionView: View {
    @EnvironmentObject private var navigationViewModel: NavigationViewModel
    
    // MARK: - Settings
    @State private var showingSettings = false
    @State private var showingHistory = false
    @AppStorage("preferPredictions") private var preferPredictions = false
    
    private var settingsSections: [SettingsSection] {
            [
                SettingsSection(title: "Session", items: [
                    SettingItem(
                        title: "Predictions (Only use with Unlimited LTE)",
                        iconName: "waveform",
                        iconColor: .blue,
                        type: .toggle($preferPredictions)
                    )
                ]),
                SettingsSection(title: "Account", items: [
                    SettingItem(
                        title: "Sign out",
                        iconName: "rectangle.portrait.and.arrow.right",
                        iconColor: .red,
                        type: .action(signOut)
                    )
                ]),

            ]
        }
    
    // For navigation
    let startSession: () -> Void
    
    private func signOut() {
        do {
            try Auth.auth().signOut()
            navigationViewModel.signedOut()
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.mint.opacity(0.35), Color(.systemBackground).opacity(1)]),
                startPoint: .top,
                endPoint: UnitPoint(x: 0.5, y: 0.8)
            )
            .edgesIgnoringSafeArea(.all)
            
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.mint
                ]),
                center: .top,
                startRadius: 5,
                endRadius: 400
            )
            .blendMode(.overlay)
            .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading) {
                Button(action: { showingSettings.toggle() }) {
                    HStack {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
                }
                .foregroundColor(Color.white)
                .padding(13)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1).fill(Color.black.opacity(0.4)))
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .sheet(isPresented: $showingSettings) {
                    SettingsView(sections: settingsSections)
                        .presentationDetents([.medium, .large])
                }
                .buttonStyle(ScaleButtonStyle())
                
                Button(action: { showingHistory.toggle() }) {
                    HStack {
                        Image(systemName: "calendar")
                        Text("History")
                    }
                }
                .foregroundColor(Color.white)
                .padding(13)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1).fill(Color.black.opacity(0.4)))
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .sheet(isPresented: $showingHistory) {
                    HistoryView(historyViewModel: HistoryViewModel())
                        .presentationDetents([.medium, .large])
                }
                .buttonStyle(ScaleButtonStyle())
                
                Spacer()
            }
            .padding()
            
            VStack {
                Text("Home")
                    .foregroundColor(.primary)
                    .fontWeight(.bold)
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                
                Text("Ready to capturing your navigation? ")
                Button("Start Session", action: startSession)
                    .frame(width: 340)
                    .padding()
                    .background(Color(red: 0.25, green: 0.8, blue: 0.8))
                    .foregroundStyle(Color.primary)
                    .font(.headline)
                    .cornerRadius(20)
                    .buttonStyle(ScaleButtonStyle())
            }
        }
    }
}

#Preview {
    StartSessionView(startSession: {})
        .environmentObject(NavigationViewModel())
        .preferredColorScheme(.dark)
}
