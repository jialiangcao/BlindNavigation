//
//  AuthView.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 4/26/25.
//

import SwiftUI

struct AuthView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color("accent").opacity(0.7), Color(.systemBackground).opacity(1)]),
                    startPoint: .top,
                    endPoint: UnitPoint(x: 0.5, y: 0.8)
                )
                .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Image("bn_logo-removebg")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200)
                    Text("Blind Navigator")
                        .fontWeight(.bold)
                        .font(.largeTitle)
                    Text("Improving accessibility, one step at a time.")
                        .font(.subheadline)
                        .opacity(0.7)
                                        
                    // Login
                    VStack {
                        NavigationLink(destination: SignUpView()) {
                            Label("Sign up", systemImage: "arrow.up")
                                .frame(width: 340)
                        }
                        .padding()
                        .background(Color("accent"))
                        .foregroundStyle(Color.primary)
                        .cornerRadius(20)
                                                
                        NavigationLink(destination: SignInView()) {
                            Label("Log In", systemImage: "arrow.right")
                                .frame(width: 340)
                        }
                        .padding()
                        .background(Color.clear)
                        .foregroundStyle(Color.primary)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.primary, lineWidth: 2)
                        )
                    }
                }
            }
        }
    }
}

#Preview {
    AuthView()
}
