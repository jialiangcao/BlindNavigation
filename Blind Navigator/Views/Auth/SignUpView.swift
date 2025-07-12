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
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    
    func signUpAndPush () {
        authViewModel.signUp { signUpSuccess in
            if signUpSuccess {
                withAnimation(.easeInOut) {
                    navigationViewModel.setStartSessionView()
                }
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(
                gradient: Gradient(colors: [Color("accent").opacity(0.7), Color(.systemBackground)]),
                startPoint: .top,
                endPoint: UnitPoint(x: 0.5, y: 0.8)
            )
            .edgesIgnoringSafeArea(.all)
            
            if let error = authViewModel.errorMessage {
                NotificationPopup(
                    title: authViewModel.errorMessage!,
                    systemIconName: "exclamationmark.triangle",
                    backgroundColor: .red
                )
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.easeIn(duration: 0.3), value: error)
                .zIndex(1)
            }
            
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
                
                SecureField("Create Password", text: $authViewModel.signInPassword)
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
                
                Button(action: signUpAndPush) {
                    Label("Sign Up", systemImage: "arrow.up")
                        .frame(width: 340)
                }
                .padding()
                .background(Color("accent"))
                .foregroundStyle(Color.white)
                .cornerRadius(20)
                
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

