//
//  SignIn.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 4/27/25.
//

import SwiftUI
import FirebaseAuth

struct SignInView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
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
                Text("Log In")
                    .fontWeight(.bold)
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding()
                
                TextField("Email Address", text: $authViewModel.signInEmail)
                .frame(width: 340)
                .padding()
                .background(Color.white)
                .foregroundStyle(Color.black)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.black.opacity(0.6), lineWidth: 2)
                )
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .keyboardType(.default)
                
                SecureField("Password", text: $authViewModel.signInPassword)
                .frame(width: 340)
                .padding()
                .background(Color.white)
                .foregroundStyle(Color.black)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.black.opacity(0.6), lineWidth: 2)
                )
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .keyboardType(.default)
                
                
                Button(action: authViewModel.signIn) {
                    Label("Log In", systemImage: "arrow.right")
                        .frame(width: 340)
                }
                .padding()
                .background(Color.mint)
                .foregroundStyle(Color.white)
                .cornerRadius(20)
                
                Button(action: authViewModel.resetPassword) {
                    Text("Forgot Password?")
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
                
                if authViewModel.errorMessage != nil {
                    Text(authViewModel.errorMessage!)
                            .foregroundColor(.red)
                            .padding(.top, 10)
                            .multilineTextAlignment(.center)
                }
            }
            .padding()
        }
    }
}

#Preview {
    SignInView()
        .environmentObject(AuthViewModel())
}


