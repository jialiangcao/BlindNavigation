//
//  StartSessionView.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 5/28/25.
//
import SwiftUI
import FirebaseAuth

struct StartSessionView: View {
    // MARK: - Settings
    @State private var showingSettings = false
    @AppStorage("preferPredictions") private var preferPredictions = false
    
    private var settingsSections: [SettingsSection] {
            [
                SettingsSection(title: "Session", items: [
                    SettingItem(
                        title: "Predictions (Requires data)",
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
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.mint.opacity(0.2), .white]),
                startPoint: .top,
                endPoint: UnitPoint(x: 0, y: 0.4)
            )
            .edgesIgnoringSafeArea(.all)
            
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.mint.opacity(0.4)
                ]),
                center: .top,
                startRadius: 5,
                endRadius: 400
            )
            .blendMode(.overlay)
            .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading) {
                Button(action: { showingSettings.toggle() }) {
                    Image(systemName: "gear")
                }
                .padding(13)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1).fill(Color.white))
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .sheet(isPresented: $showingSettings) {
                    SettingsView(sections: settingsSections)
                        .presentationDetents([.medium, .large])
                }
                .buttonStyle(ScaleButtonStyle())

                
                Spacer()
            }
            .padding()
            
            VStack {
                Text("Start Session")
                    .fontWeight(.bold)
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                
                Text("Ready to capturing your navigation? ")
                Button("Start Session", action: startSession)
                    .frame(width: 340)
                    .padding()
                    .background(Color.mint)
                    .foregroundStyle(Color.white)
                    .cornerRadius(20)
                    .buttonStyle(ScaleButtonStyle())
            }
        }
    }
}

#Preview {
    StartSessionView(startSession: {})
}
