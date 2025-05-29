//
//  StartSessionView.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 5/28/25.
//
import SwiftUI
import FirebaseAuth

struct StartSessionView: View {
    let startSession: () -> Void
    
    private func signOut() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
    }
    
    // Placeholder UI until more features are specified
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
                
                Button(action: signOut) {
                    Text("Sign Out")
                }
            }
        }
    }
}

#Preview {
    StartSessionView(startSession: {})
}
