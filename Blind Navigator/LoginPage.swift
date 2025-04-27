//
//  LoginPage.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 4/26/25.
//

import SwiftUI

struct LoginPage: View {
    func signup() {
        print("Signing up")
    }
    
    func login() {
        print("Logging in")
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

            VStack {
                Text("Blind Navigator")
                    .fontWeight(.bold)
                    .font(.largeTitle)
                Text("Making navigation easier")
                    .font(.subheadline)
                    .opacity(0.7)
                Image("blindPersonColor")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 500, height: 500)
                    .shadow(radius: 3)
                
                // Login
                VStack {
                    Button(action: signup) {
                        Label("Sign up", systemImage: "arrow.up")
                        .frame(width: 320)
                    }
                    .padding()
                    .background(Color.white)
                    .foregroundStyle(Color.black)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.black.opacity(0.6), lineWidth: 2)
                    )
                    
                    Button(action: login) {
                        Label("Log In", systemImage: "arrow.right")
                            .frame(width: 320)
                    }
                    .padding()
                    .background(Color.mint)
                    .foregroundStyle(Color.white)
                    .cornerRadius(20)
                }
            }
        }
    }
}

#Preview {
    LoginPage()
}
