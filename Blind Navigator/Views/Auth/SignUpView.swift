//
//  SignUp.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 4/27/25.
//

import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
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

                Text("Sign Up")
                    .fontWeight(.bold)
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding()
                
                TextField("Email Address", text: $authViewModel.signUpEmail)
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
                
                SecureField("Create Password", text: $authViewModel.signUpPassword)
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
                
                Text("Password must be atleast 8 characters long")
                    .font(.caption)
                    .fontWeight(.light)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                SecureField("Confirm Password", text: $authViewModel.signUpConfirmPassword)
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
                
                Button(action: authViewModel.signUp) {
                    Label("Sign Up", systemImage: "arrow.up")
                        .frame(width: 340)
                }
                .padding()
                .background(Color("accent"))
                .foregroundStyle(Color.white)
                .cornerRadius(20)
                
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
    SignUpView()
        .environmentObject(AuthViewModel())
        .preferredColorScheme(.dark)
}

