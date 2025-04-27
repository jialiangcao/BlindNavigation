//
//  SignUp.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 4/27/25.
//

import SwiftUI
import FirebaseAuth

struct SignUp: View {
    @State private var email: String = ""
    @State private var desiredPassword: String = ""
    @State private var passwordConfirmation: String = ""
    
    func createAccount() {
        if email == "" || isValidEmail(email) == false {
            print("Please enter a valid email address")
            return
        }
        if desiredPassword == "" {
            print("Please enter a password")
            return
        }
        if passwordConfirmation == "" {
            print("Please confirm your password")
            return
        }
        if desiredPassword.count<8 {
            print("Password must be at least 8 characters long")
            return
        }
        if desiredPassword != passwordConfirmation {
            print("Passwords do not match")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: desiredPassword) { authResult, error in
            if let authResult = authResult {
                print("Sign-up successful")
            }
            if let error = error {
                print("Error creating user: \(error)")
                return
            }
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
            let regex = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let test = NSPredicate(format:"SELF MATCHES %@", regex)
            return test.evaluate(with: email)
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
                Text("Sign Up")
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

                SecureField(
                    "Create Password",
                    text: $desiredPassword
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
                
                Text("Password must be atleast 8 characters long")
                    .font(.caption)
                    .fontWeight(.light)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                SecureField(
                    "Confirm Password",
                    text: $passwordConfirmation
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
                
                Button(action: createAccount) {
                        Label("Sign Up", systemImage: "arrow.up")
                            .frame(width: 340)
                    }
                    .padding()
                    .background(Color.mint)
                    .foregroundStyle(Color.white)
                    .cornerRadius(20)
            }
            .padding()
        }
    }
}

#Preview {
    SignUp()
}

