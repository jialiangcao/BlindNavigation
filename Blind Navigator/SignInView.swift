//
//  SignIn.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 4/27/25.
//

import SwiftUI
import FirebaseAuth

struct SignInView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String? = nil
    
    func authenticate() {
        errorMessage = nil
        if email == "" {
            errorMessage = "Please enter an email address"
            return
        }
        if password == "" {
            errorMessage = "Please enter a password"
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            // Firebase specific errors
            if let error = error as NSError? {
                if let errCode = AuthErrorCode(rawValue: error._code) {
                    switch errCode {
                    case .invalidCredential:
                        errorMessage = "Invalid email or password."
                    case .userNotFound:
                        errorMessage = "User not found. Please sign up."
                    case .wrongPassword:
                        errorMessage = "Invalid email or password."
                    case .networkError:
                        errorMessage = "Network error. Please try again."
                    case .tooManyRequests:
                        errorMessage = "Too many requests. Please try again later."
                    default:
                        errorMessage = "Error logging in: \(error), please try again."
                    }
                }
                return
            }
        }
    }
    
    private func requestReset() {
        guard !email.isEmpty else {
            errorMessage = "Please enter your email address."
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                errorMessage = "Password reset email sent successfully. Please check your inbox."
            }
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
            
            VStack {
                Text("Log In")
                    .fontWeight(.bold)
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding()
                
                TextField(
                    "Email Address",
                    text: $email
                )
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
                
                SecureField(
                    "Password",
                    text: $password
                )
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
                
                
                Button(action: authenticate) {
                    Label("Log In", systemImage: "arrow.right")
                        .frame(width: 340)
                }
                .padding()
                .background(Color.mint)
                .foregroundStyle(Color.white)
                .cornerRadius(20)
                
                Button(action: requestReset) {
                    Text("Forgot Password?")
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
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
}


