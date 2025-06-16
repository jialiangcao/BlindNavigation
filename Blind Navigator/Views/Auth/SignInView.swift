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
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color("accent").opacity(0.7), Color(.systemBackground)]),
                startPoint: .top,
                endPoint: UnitPoint(x: 0.5, y: 0.8)
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                Image("bn_logo-removebg")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
                Text("Log In")
                    .fontWeight(.bold)
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .foregroundStyle(Color.primary)
                    .padding()
                
                TextField("Email Address", text: $authViewModel.signInEmail)
                .frame(width: 340)
                .padding()
                .background(Color.clear)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.secondary, lineWidth: 2)
                )
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .keyboardType(.default)
                
                SecureField("Password", text: $authViewModel.signInPassword)
                .frame(width: 340)
                .padding()
                .background(Color.clear)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.secondary, lineWidth: 2)
                )
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .keyboardType(.default)
                
                
                Button(action: { authViewModel.signIn { success in
                        if success {
                            navigationViewModel.signedIn()
                        }
                    }
                }
                ) {
                    Label("Log In", systemImage: "arrow.right")
                        .frame(width: 340)
                }
                .padding()
                .background(Color("accent"))
                .foregroundStyle(Color.primary)
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
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    SignInView()
        .environmentObject(AuthViewModel())
        .preferredColorScheme(.dark)
}


